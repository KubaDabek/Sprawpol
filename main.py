from fastapi import FastAPI, Form, Request, Depends, HTTPException
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse, RedirectResponse
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, Date, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Konfiguracja bazy danych SQLite
DATABASE_URL = "sqlite:///./sprawpol.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Modele bazy danych
class Uzytkownicy(Base):
    __tablename__ = "Uzytkownicy"
    id_uzytkownika = Column(Integer, primary_key=True, index=True)
    login = Column(String(90), unique=True, index=True)
    haslo = Column(String(90))

class Prowadzacy(Base):
    __tablename__ = "Prowadzacy"
    id_prowadzacego = Column(Integer, primary_key=True, index=True)
    imie = Column(String(25))
    nazwisko = Column(String(40))

class Przedmioty(Base):
    __tablename__ = "Przedmioty"
    id_przedmiotu = Column(Integer, primary_key=True, index=True)
    nazwa = Column(String(90))

class Przypisania(Base):
    __tablename__ = "Przypisania"
    id_przypisania = Column(Integer, primary_key=True, index=True)
    id_prowadzacego = Column(Integer, ForeignKey("Prowadzacy.id_prowadzacego"))
    id_przedmiotu = Column(Integer, ForeignKey("Przedmioty.id_przedmiotu"))

class Sprawozdania(Base):
    __tablename__ = "Sprawozdania"
    id_sprawozdania = Column(Integer, primary_key=True, index=True)
    id_przypisania = Column(Integer, ForeignKey("Przypisania.id_przypisania"))
    id_uzytkownika = Column(Integer, ForeignKey("Uzytkownicy.id_uzytkownika"))
    tytul = Column(String(100))
    ocena = Column(Float)
    poprawiane = Column(Integer)
    data_oddania = Column(Date)

# Tworzenie tabel w bazie danych (jeśli nie istnieją)
Base.metadata.create_all(bind=engine)

# FastAPI Application Instance
app = FastAPI()

# Konfiguracja Jinja2 Templates
templates = Jinja2Templates(directory="templates")

# Dependency do pobierania sesji bazy danych
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Strona logowania (HTML)
@app.get("/", response_class=HTMLResponse)
async def login_page(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})

# Endpoint logowania
@app.post("/login/")
async def login(username: str = Form(...), password: str = Form(...), db: SessionLocal = Depends(get_db)):
    user = db.query(Uzytkownicy).filter(Uzytkownicy.login == username).first()
    if not user or user.haslo != password:
        raise HTTPException(status_code=401, detail="Invalid username or password")

    # Przekierowanie na stronę ze sprawozdaniami użytkownika
    return RedirectResponse(url=f"/sprawozdania/{user.id_uzytkownika}", status_code=302)

# Podstrona ze sprawozdaniami zalogowanego użytkownika
@app.get("/sprawozdania/{user_id}", response_class=HTMLResponse)
async def user_reports(user_id: int, request: Request, db: SessionLocal = Depends(get_db)):
    reports_query = (
        db.query(
            Sprawozdania,
            Przedmioty.nazwa.label("przedmiot"),
            Prowadzacy.nazwisko.label("prowadzacy")
        )
        .join(Przypisania, Sprawozdania.id_przypisania == Przypisania.id_przypisania)
        .join(Przedmioty, Przypisania.id_przedmiotu == Przedmioty.id_przedmiotu)
        .join(Prowadzacy, Przypisania.id_prowadzacego == Prowadzacy.id_prowadzacego)
        .filter(Sprawozdania.id_uzytkownika == user_id)
        .all()
    )

    return templates.TemplateResponse(
        "sprawozdania.html",
        {"request": request, "reports": reports_query}
    )
