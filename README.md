# README

# Dokument opisuje kolejne kroki w budowie aplikacji z repozytorium

**1. Punt ten opisuje działania w ramach brancha "Start-stan-aktualny"**

**1.1. Utworzenie aplikacji**

**wersja a) - w terminalu**
    
    rails new Nazwa_aplikacji --css tailwind


**wersja b) - w edytorze RubyMine**

File -> New Project   
w polu "Extra options" wpisać: --css tailwind

![img.png](app/assets/images/img.png)

    
**1.2. Budowa pierwszego rusztowania dla klasy _Group_**


Tools -> Run Rails Generator : rails generate scaffold Group nazwa:string

Tools -> Rake Tasks : db:migrate

- można w tym momencie uruchomić serwer i sprawdzić działanie aplikacji, w przeglądarce 127.0.0.1:3000/groups 

**1.3. Druga klasa _Students_**

Tools -> Run Rails Generator : rails generate scaffold Student imie:string nazwisko:string album:string group:references

_ostatnia klauzula tworzy powiązanie z klasą Group (klucz obcy)_

- nalezy wykonać migrację do bazy danych
- nalezy dodać relację do klasy _Group_ w pliku modelu, w klasie _Student_ wpis utworzył generator scaffold
 
![app/assets/images/img_3.png](app/assets/images/img_3.png)

**1.3. Klasa _Fields_**

Tools -> Run Rails Generator : rails generate scaffold Field nazwa:string 

- w następnym kroku dodajemy powiązanie z klasą Group

Tools -> Run Rails Generator : rails generate migration AddFieldToGroups field:references

- w kolejnym kroku (oczywiście po migracji) należy wykonać edycję modeli _Field_ i _Group_

![app/assets/images/img_1.png](app/assets/images/img_1.png)

![app/assets/images/img_2.png](app/assets/images/img_2.png)
- obługa relacji:
    - zmiany w kontrolerze _Students_ - do metody student_params dodajemy :field_id


![app/assets/images/img_4.png](app/assets/images/img_4.png)
    
- kolejne zmiany dotyczą widoków dla klasy _Student_:
  - widok _form.html.erb - dodajemy pole wyboru dla pola field_id

![app/assets/images/img_5.png](app/assets/images/img_5.png)
      
_na obrazku nie jest widoczny opis klasy css ale nie ma to znaczenia dla działania aplikacji_
- zmiany w widoku _student.html.erb - dodajemy wyświetlanie nazwy grupy do której należy student


![app/assets/images/img_6.png](app/assets/images/img_6.png)
  
**To koniec działań w ramach gałęzi repozytorium Start-stan-aktualny**     


**2. Add-Course**

**2.1. Utworzenie klasy _Course_**
    
    Tools -> Run Rails Generator : rails generate scaffold Course nazwa:string ects:integer

- wykonujemy migrację do bazy danych

**2.2. Powiązanie klasy _Course_ z klasą _Group_**
    - wygenerowanie migracji tworzącej tabelę łączącą grupy z kursami (wiele do wielu)

    Tools -> Run Rails Generator : rails generate migration CreateJoinTableCoursesGroups course:references group:references


- wykonujemy migrację do bazy danych
 
**2.2. Edycja modeli**
- edytujemy modele _Course_ i _Group_ aby dodać relacje wiele do wielu

![img_7.png](app/assets/images/img_7.png)

![img_8.png](app/assets/images/img_8.png)

- edytujemy kontroler _Groups_ aby umożliwić przypisanie kursów do grupy

![img_9.png](app/assets/images/img_9.png)
- edytujemy widoki dla klasy _Group_ aby umożliwić przypisanie kursów do grupy
  - widok _form.html.erb_

![img_10.png](app/assets/images/img_10.png)
  - widok _group.html.erb_

![img_11.png](app/assets/images/img_11.png)


**To kończy operacje w gałęzi Add-Course**

**3. Add-Grade**

**3.1. Utworzenie tabeli pośredniej pomiędzy _Course_ a _Student_**
W tym przypadku wykorzystujemy tabelę łączącą Course i Student (podobnie jak w przypadku _Group_ i _Course_) ale musimmy ją zmodyfikować.
W pierwszym kroku tworzymy tabelę pośrednią podobnie jak w poprzednim przypadku.
    
    Tools -> Run Rails Generator : rails generate migration CreateJoinTableCoursesStudenrts course:references student:references

- wykonujemy migrację do bazy danych
- następnie tworzymy migrację dodającą kolumnę _grade_ do tabeli łączącej i zmieniamy nazwę tabeli na Grades

    Tools -> Run Rails Generator : rails generate migration AddGradeToCourseStudent grade:integer
- w pliku migracji zmieniamy nazwę tabeli na _grades_ i dodajemy klucz główny kompozytowy

![img_13.png](app/assets/images/img_13.png)

- wykonujemy migrację do bazy danych

**3.2. Edycja modeli**
- tworzymy plik modelu _Grade_ (grade.rb)

![img_14.png](app/assets/images/img_14.png)

- edytujemy modele _Course_ i _Student_ aby dodać relacje wiele do wielu przez tabelę _Grades_

![img_15.png](app/assets/images/img_15.png)

![img_16.png](app/assets/images/img_16.png)

 **3.3. Edycja kontrolera _Courses_**
 
Koncepcja obsługi ocen polega na tym, że oceny będą dopisywane w widoku kursów, dla każdego kursy będą wypisane grupy i dodany przycisk do wywołania widoku z ocenami, następnie w tym widoku będą widoczni studenci wraz z ich ocenami oraz przycisk do edycji ocen który skieruje do formularza pozwalającego na edycję po naciśnięciu przycisku "Zapisz" użytkownik zostanie przekirowany do widoku ocen.
W związku z tym potrzebne będą następujące metody w kontrolerze _Courses_:
- metoda _grade_ - wyświetla widok z ocenami dla danej grupy

![img.png](app/assets/images/img_17.png)

- metoda _grade_set_ - wyświetla formularz do edycji ocen dla danej grupy

![img_4.png](app/assets/images/img_21.png)

- metoda _grade_save_ - zapisuje oceny do bazy

![img_3.png](app/assets/images/img_20.png)

- wszystkie te nowe metody muszą być dodane do listy metod dla których wykonana jest metoda _before_action :set_course_

![img_2.png](app/assets/images/img_19.png)

**3.4. Dodanie tras do pliku _config/routes.rb_**

- dodajemy trzy nowe trasy do obsługi ocen



![img_1.png](app/assets/images/img_18.png)

**3.5. Edycja widoków dla klasy _Course_**

- edycja widoku __course.html.erb_ - dodanie przycisku do widoku ocen dla danej grupy
- utworzenie widoku _grade.html.erb_ - wyświetlanie ocen dla danej grupy
- utworzenie widoku _grade_set.html.erb_ - formularz do edycji ocen dla danej grupy

Pliki są widoków dostepne w repozytorium.