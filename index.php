<?php
session_start();
$conn = new mysqli("localhost", "root", "", "sprawpol3");
if ($conn->connect_error) die("Błąd połączenia z bazą: " . $conn->connect_error);

if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: index.php");
    exit;
}

$komunikat = "";
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['rejestruj'])) {
    $nowy_login = $_POST['new_login'];
    $nowe_haslo = $_POST['new_password'];
    $stmt = $conn->prepare("SELECT * FROM Uzytkownicy WHERE login = ?");
    $stmt->bind_param("s", $nowy_login);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($result->num_rows > 0) {
        $komunikat = "⚠️ Taki login już istnieje!";
    } else {
        $hashed = password_hash($nowe_haslo, PASSWORD_DEFAULT);
        $stmt = $conn->prepare("INSERT INTO Uzytkownicy (login, haslo) VALUES (?, ?)");
        $stmt->bind_param("ss", $nowy_login, $hashed);
        $komunikat = $stmt->execute() ? "✅ Rejestracja zakończona sukcesem." : "❌ Błąd rejestracji.";
    }
    $stmt->close();
}

if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['login'])) {
    $login = $_POST['login'];
    $haslo = $_POST['haslo'];
    $stmt = $conn->prepare("SELECT id_uzytkownika, haslo FROM Uzytkownicy WHERE login = ?");
    $stmt->bind_param("s", $login);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($row = $result->fetch_assoc()) {
        if (password_verify($haslo, $row['haslo'])) {
            $_SESSION['id_uzytkownika'] = $row['id_uzytkownika'];
            $_SESSION['login'] = $login;
        } else $komunikat = "❌ Nieprawidłowe hasło.";
    } else $komunikat = "❌ Użytkownik nie istnieje.";
    $stmt->close();
}

if (isset($_POST['nowe_sprawozdanie']) && isset($_SESSION['id_uzytkownika'])) {
    $tytul = $_POST['tytul'];
    $id_przypisania = $_POST['id_przypisania'];
    $data = date('Y-m-d');
    $stmt = $conn->prepare("INSERT INTO Sprawozdania (id_uzytkownika, id_przypisania, tytul, data_oddania) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("iiss", $_SESSION['id_uzytkownika'], $id_przypisania, $tytul, $data);
    $stmt->execute();
    $stmt->close();
}

if (isset($_GET['usun']) && isset($_SESSION['id_uzytkownika'])) {
    $id = intval($_GET['usun']);
    $stmt = $conn->prepare("DELETE FROM Sprawozdania WHERE id_sprawozdania = ? AND id_uzytkownika = ?");
    $stmt->bind_param("ii", $id, $_SESSION['id_uzytkownika']);
    $stmt->execute();
    $stmt->close();
    header("Location: index.php");
    exit;
}

if (isset($_POST['edytuj']) && isset($_SESSION['id_uzytkownika'])) {
    $id = intval($_POST['id_sprawozdania']);
    $tytul = $_POST['tytul'];
    $poprawiane = isset($_POST['poprawiane']) ? 1 : 0;
    $stmt = $conn->prepare("UPDATE Sprawozdania SET tytul = ?, poprawiane = ? WHERE id_sprawozdania = ? AND id_uzytkownika = ?");
    $stmt->bind_param("siii", $tytul, $poprawiane, $id, $_SESSION['id_uzytkownika']);
    $stmt->execute();
    $stmt->close();
    header("Location: index.php");
    exit;
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
  <meta charset="UTF-8">
  <title>Sprawozdania</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>

<?php if (!isset($_SESSION['id_uzytkownika'])): ?>
  <div class="login-box">
    <h2>Logowanie</h2>
    <?php if ($komunikat): ?><p class="komunikat"><?= $komunikat ?></p><?php endif; ?>
    <form method="post">
      <label>Login</label>
      <input type="text" name="login" required>
      <label>Hasło</label>
      <input type="password" name="haslo" required>
      <button type="submit">Zaloguj się</button>
    </form>
  </div>

  <div class="register-box">
    <h2>Rejestracja</h2>
    <form method="post">
      <label>Nowy login</label>
      <input type="text" name="new_login" required>
      <label>Nowe hasło</label>
      <input type="password" name="new_password" required>
      <button type="submit" name="rejestruj">Zarejestruj się</button>
    </form>
  </div>

<?php else: ?>
  <div class="panel">
    <h2>Witaj, <?= htmlspecialchars($_SESSION['login']) ?>!</h2>
    <a href="?logout=1">Wyloguj się</a>

    <h3>Twoje sprawozdania</h3>

    <form method="get" class="filter-form">
      <label>Sortuj według:</label>
      <select name="sort">
        <option value="data_oddania">Data oddania</option>
        <option value="ocena">Ocena</option>
        <option value="tytul">Tytuł</option>
      </select>
      <button type="submit">Zastosuj</button>
    </form>

    <table>
      <tr>
        <th>Tytuł</th>
        <th>Data</th>
        <th>Ocena</th>
        <th>Poprawiane</th>
        <th>Przedmiot</th>
        <th>Prowadzący</th>
        <th>Akcje</th>
      </tr>
      <?php
        $id = $_SESSION['id_uzytkownika'];
        $sort = $_GET['sort'] ?? 'data_oddania';
        $allowed = ['data_oddania', 'ocena', 'tytul'];
        if (!in_array($sort, $allowed)) $sort = 'data_oddania';

        $sql = "SELECT s.*, p.nazwa, CONCAT(pr.imie, ' ', pr.nazwisko) AS prowadzacy
                FROM Sprawozdania s
                JOIN Przypisania ps ON s.id_przypisania = ps.id_przypisania
                JOIN Przedmioty p ON ps.id_przedmiotu = p.id_przedmiotu
                JOIN Prowadzacy pr ON ps.id_prowadzacego = pr.id_prowadzacego
                WHERE s.id_uzytkownika = ?
                ORDER BY $sort DESC";

        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $res = $stmt->get_result();

        while ($row = $res->fetch_assoc()):
      ?>
      <tr>
        <td><?= htmlspecialchars($row['tytul']) ?></td>
        <td><?= $row['data_oddania'] ?></td>
        <td><?= $row['ocena'] ?? 'Brak' ?></td>
        <td><?= $row['poprawiane'] ? 'Tak' : 'Nie' ?></td>
        <td><?= $row['nazwa'] ?></td>
        <td><?= $row['prowadzacy'] ?></td>
        <td>
          <form method="post" style="display:inline;">
            <input type="hidden" name="id_sprawozdania" value="<?= $row['id_sprawozdania'] ?>">
            <input type="text" name="tytul" value="<?= htmlspecialchars($row['tytul']) ?>" required>
            <label><input type="checkbox" name="poprawiane" <?= $row['poprawiane'] ? 'checked' : '' ?>> Poprawiane</label>
            <button type="submit" name="edytuj">Zapisz</button>
          </form>
          <a href="?usun=<?= $row['id_sprawozdania'] ?>" onclick="return confirm('Na pewno usunąć?')">🗑</a>
        </td>
      </tr>
      <?php endwhile; $stmt->close(); ?>
    </table>

    <h3>Dodaj nowe sprawozdanie</h3>
    <form method="post">
      <label>Tytuł</label>
      <input type="text" name="tytul" required>
      <label>Przedmiot i prowadzący</label>
      <select name="id_przypisania" required>
        <?php
        $res = $conn->query("SELECT ps.id_przypisania, p.nazwa, CONCAT(pr.imie, ' ', pr.nazwisko) AS prowadzacy
                             FROM Przypisania ps
                             JOIN Przedmioty p ON ps.id_przedmiotu = p.id_przedmiotu
                             JOIN Prowadzacy pr ON ps.id_prowadzacego = pr.id_prowadzacego");
        while ($r = $res->fetch_assoc()):
        ?>
          <option value="<?= $r['id_przypisania'] ?>"><?= $r['nazwa'] ?> – <?= $r['prowadzacy'] ?></option>
        <?php endwhile; ?>
      </select>
      <button type="submit" name="nowe_sprawozdanie">Dodaj</button>
    </form>
  </div>
<?php endif; ?>
</body>
</html>