-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 29, 2025 at 11:53 AM
-- Wersja serwera: 10.4.32-MariaDB
-- Wersja PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sprawpol3`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Prowadzacy`
--

CREATE TABLE `Prowadzacy` (
  `id_prowadzacego` int(11) NOT NULL,
  `imie` char(25) NOT NULL,
  `nazwisko` char(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Prowadzacy`
--

INSERT INTO `Prowadzacy` (`id_prowadzacego`, `imie`, `nazwisko`) VALUES
(1, 'Adam', 'Duszeńko'),
(2, 'Mirosława', 'Kępińska');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Przedmioty`
--

CREATE TABLE `Przedmioty` (
  `id_przedmiotu` int(11) NOT NULL,
  `nazwa` char(90) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Przedmioty`
--

INSERT INTO `Przedmioty` (`id_przedmiotu`, `nazwa`) VALUES
(1, 'Fizyka'),
(2, 'Bazy danych');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Przypisania`
--

CREATE TABLE `Przypisania` (
  `id_przypisania` int(11) NOT NULL,
  `id_prowadzacego` int(11) NOT NULL,
  `id_przedmiotu` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Przypisania`
--

INSERT INTO `Przypisania` (`id_przypisania`, `id_prowadzacego`, `id_przedmiotu`) VALUES
(1, 1, 2),
(2, 2, 1);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Sprawozdania`
--

CREATE TABLE `Sprawozdania` (
  `id_sprawozdania` int(11) NOT NULL,
  `id_przypisania` int(11) NOT NULL,
  `id_uzytkownika` int(11) NOT NULL,
  `tytul` char(100) DEFAULT NULL,
  `ocena` double DEFAULT NULL,
  `poprawiane` int(11) DEFAULT NULL,
  `data_oddania` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Sprawozdania`
--

INSERT INTO `Sprawozdania` (`id_sprawozdania`, `id_przypisania`, `id_uzytkownika`, `tytul`, `ocena`, `poprawiane`, `data_oddania`) VALUES
(1, 1, 1, 'testowe sprawozdanie', 3, 0, '2025-03-18');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Uzytkownicy`
--

CREATE TABLE `Uzytkownicy` (
  `id_uzytkownika` int(11) NOT NULL,
  `login` char(90) NOT NULL,
  `haslo` char(90) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Uzytkownicy`
--

INSERT INTO `Uzytkownicy` (`id_uzytkownika`, `login`, `haslo`) VALUES
(1, 'bryła', 'test');

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `Prowadzacy`
--
ALTER TABLE `Prowadzacy`
  ADD PRIMARY KEY (`id_prowadzacego`),
  ADD UNIQUE KEY `id_prowadzacego` (`id_prowadzacego`);

--
-- Indeksy dla tabeli `Przedmioty`
--
ALTER TABLE `Przedmioty`
  ADD PRIMARY KEY (`id_przedmiotu`),
  ADD UNIQUE KEY `id_przedmiotu` (`id_przedmiotu`);

--
-- Indeksy dla tabeli `Przypisania`
--
ALTER TABLE `Przypisania`
  ADD PRIMARY KEY (`id_przypisania`,`id_prowadzacego`,`id_przedmiotu`),
  ADD UNIQUE KEY `id_przypisania` (`id_przypisania`),
  ADD KEY `id_prowadzacego` (`id_prowadzacego`),
  ADD KEY `id_przedmiotu` (`id_przedmiotu`);

--
-- Indeksy dla tabeli `Sprawozdania`
--
ALTER TABLE `Sprawozdania`
  ADD PRIMARY KEY (`id_sprawozdania`,`id_przypisania`,`id_uzytkownika`),
  ADD UNIQUE KEY `id_sprawozdania` (`id_sprawozdania`),
  ADD KEY `id_przypisania` (`id_przypisania`),
  ADD KEY `id_uzytkownika` (`id_uzytkownika`);

--
-- Indeksy dla tabeli `Uzytkownicy`
--
ALTER TABLE `Uzytkownicy`
  ADD PRIMARY KEY (`id_uzytkownika`),
  ADD UNIQUE KEY `id_uzytkownika` (`id_uzytkownika`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Prowadzacy`
--
ALTER TABLE `Prowadzacy`
  MODIFY `id_prowadzacego` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Przedmioty`
--
ALTER TABLE `Przedmioty`
  MODIFY `id_przedmiotu` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Przypisania`
--
ALTER TABLE `Przypisania`
  MODIFY `id_przypisania` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Sprawozdania`
--
ALTER TABLE `Sprawozdania`
  MODIFY `id_sprawozdania` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `Uzytkownicy`
--
ALTER TABLE `Uzytkownicy`
  MODIFY `id_uzytkownika` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Przypisania`
--
ALTER TABLE `Przypisania`
  ADD CONSTRAINT `Przypisania_ibfk_1` FOREIGN KEY (`id_prowadzacego`) REFERENCES `Prowadzacy` (`id_prowadzacego`),
  ADD CONSTRAINT `Przypisania_ibfk_2` FOREIGN KEY (`id_przedmiotu`) REFERENCES `Przedmioty` (`id_przedmiotu`);

--
-- Constraints for table `Sprawozdania`
--
ALTER TABLE `Sprawozdania`
  ADD CONSTRAINT `Sprawozdania_ibfk_1` FOREIGN KEY (`id_przypisania`) REFERENCES `Przypisania` (`id_przypisania`),
  ADD CONSTRAINT `Sprawozdania_ibfk_2` FOREIGN KEY (`id_uzytkownika`) REFERENCES `Uzytkownicy` (`id_uzytkownika`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
