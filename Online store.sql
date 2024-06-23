--Structuri alternative ?i repetitive

--1.S? se afi?eze username-ul si id-ul utilizatorii care au id-ul cuprins intre 200 ?i 220.

declare
v_id USERS.ID_USER%TYPE;
v_username USERS.USERNAME%TYPE;
begin
FOR v_id IN 200..220 LOOP
        BEGIN
            SELECT username INTO v_username
            FROM USERS
            WHERE id_user = v_id;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Username: ' || v_username);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Daca nu se gaseste un user cu id = v_id atunci trecem mai departe
                NULL;
        END;
    END LOOP;
end;
/

--2.	S? se afi?eze nume produselor care au id-ul cuprins intre 10 ?i 20. Daca nu exista un produs cu unul dintre aceste id-uri sa se afi?eze un mesaj .
DECLARE
    v_id PRODUCTS.ID_PRODUCT%TYPE := 10;  -- Ini?ializeaz? v_id la 10
    v_product_name PRODUCTS.PRODUCT_NAME%TYPE;
BEGIN
    WHILE v_id <= 20 LOOP
        BEGIN
            SELECT product_name INTO v_product_name FROM products
            WHERE id_product = v_id;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Product Name: ' || v_product_name);      
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Nu exista produs cu id-ul: ' || v_id);
        END;
        v_id := v_id + 1;  
    end loop;
END;
/

--3.	S? se selecteze produsele care au  id-ul cuprins între 10 ?i 15. S? se închid? structura repetititv? cand se întalneste un produs cu pre?ul de achizi?ie mai mic decat cel mediu.

DECLARE
    v_id PRODUCTS.ID_PRODUCT%TYPE := 10;  -- Ini?ializeaz? v_id la 10
    v_purchase_price PRODUCTS.PRODUCT_NAME%TYPE;
    v_average_price PRODUCTS.PURCHASE_PRICE%TYPE;
BEGIN
    select avg(PURCHASE_PRICE) into v_average_price from products;
    DBMS_OUTPUT.PUT_LINE('Pretul mediu de achizitie este ' || v_average_price || '€ ');      
    loop
        select purchase_price into v_purchase_price from products 
        where id_product=v_id;
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id ||' Pret de achizitie: '||v_purchase_price|| '€ ');      
        v_id:=v_id+1;
        exit when v_purchase_price<v_average_price or v_id>20;
    end loop;
END;
/

--4.	S? se afi?eze username-ul utilizatorului cu id 204. Daca username-ul este ‘Mihaela’ atunci s? se modifice tipul de utilizator (user_type) în ‘admin’.

DECLARE
v_username USERS.USERNAME%TYPE;
v_user_type USERS.USER_TYPE%TYPE;
BEGIN
select username, user_type into v_username,v_user_type from users where id_user=204;
dbms_output.put_line('Username: '|| v_username || ' |  User type:'||v_user_type);
if v_username='Mihaela' then
    Update USERS 
    Set user_type='admin'
    where id_user=204;
end if;
END;
/

--5.	S? se afi?eze produsele cu id cuprins între 7 ?i 15. S? se calculeze costul de transport astfel:
a.	Dac? produsul face parte din categoria ‘Laptops’ costul este 20
b.	Dac? produsul face parte din categoria ‘TV’ costul este 100
c.	Dac? produsul face parte din alta categorie atunci costul este 35

DECLARE
    v_id PRODUCTS.ID_PRODUCT%TYPE := 7; 
    v_product_name PRODUCTS.PRODUCT_NAME%TYPE;
    v_category_name CATEGORIES.CATEGORY_NAME%TYPE;
    v_shipping_cost NUMBER;
BEGIN
    WHILE v_id <= 15 LOOP
        BEGIN
            SELECT product_name p, category_name c INTO v_product_name, v_category_name FROM products p,categories c
            WHERE c.id_category=p.id_category AND p.id_product = v_id;

            CASE v_category_name
                WHEN 'Laptops' THEN v_shipping_cost := 20;
                WHEN 'TV' THEN v_shipping_cost := 100;
                ELSE v_shipping_cost := 35;
            END CASE;
          
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Product Name: ' || v_product_name || ', Category: ' || v_category_name || ', Shipping Cost: ' || v_shipping_cost);
        END;
        v_id := v_id + 1;
    END LOOP;
END;
/


--Tratarea excep?iilor

--1.	S? se afi?eze userul cu id-ul 28. S? se trateze eroarea ap?rut? în cazul în care nu exist? nici un user cu acest id.
DECLARE
v_username USERS.username%TYPE;
BEGIN
select username into v_username from users where id_user=103;
dbms_output.put_line('Utilizator : '||v_username);

EXCEPTION
when no_data_found then
dbms_output.put_line('Nu exista utilizatorul cu id 103 ');
END;
/
 

--2.	S? se afi?eze id-ul utilizatorului cu username-ul ‘Dani’. S? se trateze eroarea în cazul în care sunt mai mul?i utilizatori cu acelasi usename.
DECLARE
v_id_user USERS.id_user%TYPE;
BEGIN
select id_user into v_id_user from users where username='Dani';
dbms_output.put_line('Id utilizator : '||v_id_user);

EXCEPTION
when too_many_rows then
dbms_output.put_line('Sunt mai multi utilizatori cu username-ul Dani.');

END;
/
 

--3.	S? se m?reasc? stocul cu 10 unit??i pentru produsul cu id=999. S? se declan?eze o excep?ie prin care sa fie avertizat utilizatorul c? nu s- a produs nici o modificare.

DECLARE
invalid_exception exception;
BEGIN
update products
set stock=stock+10
where id_product=999;
if sql%notfound then
raise invalid_exception;
end if;
EXCEPTION
when invalid_exception then
dbms_output.put_line('Nu exista produsul cu acest id');
when others then
dbms_output.put_line('A aparut o eroare, nu se poate actualiza stocul produsului');
END;
/
 

--4.	S? se modifice numarul de telefon al utilizatorului cu id=10. Daca acesta nu exist?, s? se trateze excep?ia. S? se atribuie excep?iei un cod ?i un mesaj de eroare care sa fie afisat utilizatorului.

declare
invalid_user exception;
pragma exception_init(invalid_user,-20999);
begin
update users
set phone_number='0799443221'
where id_user=10;
if sql%notfound then
raise_application_error(-20999,'Id user invalid!');
end if;
exception
when invalid_user then
dbms_output.put_line('Nu exista utilizatorul cu acest id----'||SQLCODE||'-----'||SQLERRM);
end;
/
 

--5.	S? se afi?eze suma total? a comenzii cu id-ul=999. Daca aceasta nu exist? atunci, s? se invoce în mod explicit excep?ia predefinita ‘no_data_found’.

DECLARE
v_suma ORDER_LINES.PRICE%TYPE;
BEGIN 

select sum(price*quantity) into v_suma from order_lines 
group by id_order
having id_order=999;
if sql%notfound then
raise no_data_found;
end if;

dbms_output.put_line('Suma totala a comenzii 999 este = '||v_suma);

EXCEPTION 
when no_data_found then 
dbms_output.put_line('Nu exista nici o comanda cu acest id');
END;


--Gestionarea cursorilor: implici?i si explici?i

--1.	S? se m?reasc? stocul produselor care fac parte din categria cu id=1. S? se afi?eze numarul de randuri modificate.
BEGIN
UPDATE products 
SET stock=stock+10
WHERE id_category=1;
dbms_output.put_line(SQL%ROWCOUNT||' randuri modificate'); 
ROLLBACK;
END;
/
 

--2.	S? se modifice denumirea produsului cu id=89, daca nu exist? atunci s? se afi?eze un mesaj corespunz?tor.

BEGIN
UPDATE products 
SET product_name='Casti bluethoot'
WHERE id_category=89;
IF sql%notfound then
dbms_output.put_line('Nu exista produsul cu id=89');
END IF;
ROLLBACK;
END;
/
 

--3.	S? se afi?eze id-ul, stocul ?i pretul de achizitie al produselor din categoria cu id=2.

declare
cursor cursor_prod is select id_product,stock,purchase_price from products where id_category=2;
prod_rec cursor_prod%rowtype;
begin
dbms_output.put_line('Lista cu produsele din categoria cu id=2');
open cursor_prod;
loop
fetch cursor_prod into prod_rec;
exit when cursor_prod%NOTFOUND;
dbms_output.put_line('Produsul: '||prod_rec.id_product||'|| Stoc disponibil= '||prod_rec.stock||' || Pret de achizitie= '||prod_rec.purchase_price);
end loop;
close cursor_prod;
end;
/
 

--4.	S? se afi?eze id-ul comenzii, numele clentului si valoarea totala pentru toate comenzile existente.

DECLARE
cursor cursor_ord is 
select o.id_order,o.client_name,sum(ol.price*ol.quantity) as total from orders o, order_lines ol 
where o.id_order=ol.id_order
group by o.id_order,client_name;
BEGIN

for order_rec in cursor_ord loop
dbms_output.put_line('Comanda nr: '||order_rec.id_order||' de la clientul: '||order_rec.client_name||' cu suma totala de '|| order_rec.total);
end loop;

END;
/


--5.	Se afi?eaz? numele categoriilor de produse ?i num?rul de produse din fiecare categorie.

DECLARE
cursor cursor_cat is 
select count(*) nr,category_name from categories c, products p where p.id_category=c.id_category
group by category_name;
BEGIN

for rec in cursor_cat loop
dbms_output.put_line('Numar de produse: '||rec.nr||' |  Categoria: '||rec.category_name);
end loop;

END;
/
 
--6.	Se afi?eaz? produsele care au stocul mai mare de 200 de unit??i.

DECLARE
cursor cursor_prod(v_stock number) is 
select id_product,stock from products where stock>v_stock
order by stock desc;
v_stoc_introdus number;
BEGIN
v_stoc_introdus:=200;

for rec in cursor_prod(v_stoc_introdus) loop
dbms_output.put_line('ID: '||rec.id_product||' |  Stoc disponibil: '||rec.stock);
end loop;

END;
/
 
--7.	S? se afi?eze utilizatorii a c?ror numere de telefon încep cu 0766.

DECLARE
cursor cursor_user(v_number varchar2) is 
select id_user,phone_number,username from users where phone_number like(v_number||'%');
v_numar_introdus VARCHAR2(50);
BEGIN
v_numar_introdus:='0766';

for rec in cursor_user(v_numar_introdus) loop
dbms_output.put_line('ID: '||rec.id_user||'   Nr tel: '||rec.phone_number||' |  Username: '||rec.username);
end loop;

END;
/


--Func?ii, proceduri, includerea acestora în pachete

--1.	S? se creeze o func?ie care verific? daca pre?ul de achizi?ie pentru un anumit produs este peste medie sau nu.
CREATE OR REPLACE FUNCTION este_pret_achizitie_peste_medie(p_id_product IN PRODUCTS.ID_PRODUCT%TYPE)
RETURN BOOLEAN
IS
    v_purchase_price PRODUCTS.PURCHASE_PRICE%TYPE;
    v_avg_purchase_price NUMBER;
BEGIN
    SELECT purchase_price INTO v_purchase_price FROM products 
    WHERE id_product = p_id_product;

    SELECT AVG(purchase_price)
    INTO v_avg_purchase_price
    FROM products;

    IF v_purchase_price > v_avg_purchase_price THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
    WHEN OTHERS THEN RETURN FALSE;
END;
/

--Apelul func?iei
DECLARE
    v_id_product number;
BEGIN
    v_id_product:=8;
    IF (este_pret_achizitie_peste_medie(v_id_product)=TRUE) THEN
        DBMS_OUTPUT.PUT_LINE('Pre?ul de achizi?ie al produsului este mai mare decât pre?ul de achizi?ie mediu.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Pre?ul de achizi?ie al produsului nu este mai mare decât pre?ul de achizi?ie mediu.');
    END IF;
END;
/
 

--2.	S? se creeze o func?ie care calculeaza suma total? cheltuit? de un utilizator pentru comenzile plasate.

CREATE OR REPLACE FUNCTION suma_totala_comenzi(p_id_user IN NUMBER)
RETURN NUMBER
IS
    val_totala NUMBER := 0;
BEGIN
    SELECT SUM(ol.price * ol.quantity) INTO val_totala FROM order_lines ol
    JOIN orders o ON ol.id_order = o.id_order
    WHERE o.id_user = p_id_user;

    RETURN val_totala;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0;
    WHEN OTHERS THEN RETURN 0;
END;
/

--Apelul func?iei
DECLARE
    v_id_user NUMBER := 205; 
    v_total_amount NUMBER;
BEGIN
    v_total_amount := suma_totala_comenzi(v_id_user);
    DBMS_OUTPUT.PUT_LINE('Suma total? a comenzilor pentru utilizatorul ' || v_id_user || ' este: ' || v_total_amount);
END;
/
 

--3.	S? se creeze o func?ie care returneaz? numarul de comenzi a utilizatorului trimis ca parametru.

CREATE OR REPLACE FUNCTION nr_comenzi(p_id_user IN NUMBER)
RETURN NUMBER
IS
    v_order_count NUMBER := 0;
BEGIN
    SELECT COUNT(DISTINCT o.id_order) INTO v_order_count FROM orders o
    WHERE o.id_user = p_id_user;

    RETURN v_order_count;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END;
/

DECLARE
    v_id_user NUMBER := 222;
    v_order_count NUMBER;
BEGIN
    v_order_count := nr_comenzi(v_id_user);
    DBMS_OUTPUT.PUT_LINE('Num?rul total de comenzi pentru utilizatorul ' || v_id_user || ' este: ' || v_order_count);
END;
/
 

--4.	S? se creeze o procedur? pentru modificarea stocului unui produs.

CREATE OR REPLACE PROCEDURE modificare_stoc (
    p_id_product IN PRODUCTS.ID_PRODUCT%TYPE,
    p_new_stock IN PRODUCTS.STOCK%TYPE
) AS
BEGIN
    UPDATE products
    SET stock = p_new_stock
    WHERE id_product = p_id_product;
    
    -- Verificare dac? actualizarea a avut loc
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Produsul cu ID-ul ' || p_id_product || ' nu a fost g?sit.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Stocul pentru produsul cu ID-ul ' || p_id_product || ' a fost actualizat la ' || p_new_stock || '.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A ap?rut o eroare: ' || SQLERRM);
END;
/

BEGIN
    modificare_stoc(999, 50); 
END;
/
 


--5.	S? se creeze o procedur? pentru adaugarea unui nou utilizator cu statutul de admin.

CREATE OR REPLACE PROCEDURE adauga_utilizator (
    p_username IN USERS.USERNAME%TYPE,
    p_password IN USERS.PASSWORD%TYPE,
    p_email IN USERS.EMAIL%TYPE,
    p_phone_number IN USERS.PHONE_NUMBER%TYPE
) AS
BEGIN
INSERT INTO users (username, password, user_type, email, creation_date, phone_numbe) VALUES (p_username, p_password, 'admin', p_email, SYSDATE, p_phone_number);
    
    DBMS_OUTPUT.PUT_LINE('Utilizatorul ' || p_username || ' a fost ad?ugat cu succes.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A ap?rut o eroare: ' || SQLERRM);
END;
/

BEGIN
    adauga_utilizator('Ionut', 'parola123', 'ionut.mihai@yahoo.com', '0784553221');
END;
/

 

--6.	S? se creeze o procedu? pentru afisare listei de produse favorite pentru un anumit utilizator.

CREATE OR REPLACE PROCEDURE afiseaza_favorite (
    p_id_user IN FAVORITES.ID_USER%TYPE
) AS
    v_product_name PRODUCTS.PRODUCT_NAME%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Lista cu produse favorite pentru utilizatorul: ' || p_id_user);
    FOR rec IN (
        SELECT p.product_name FROM favorites f
        JOIN products p ON f.id_product = p.id_product
        WHERE f.id_user = p_id_user
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('--> ' || rec.product_name);
    END LOOP;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Utilizatorul cu ID-ul ' || p_id_user || ' nu are produse favorite.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A ap?rut o eroare: ' || SQLERRM);
END;
/


BEGIN
    afiseaza_favorite(1);
END;
/
 

--7.	S? se creeze un pachet in care s? fie adaugate functia suma_totala_comenzi ?i procedura nr_comenzi.

CREATE OR REPLACE PACKAGE magazin_pck AS
    FUNCTION suma_totala_comenzi(p_id_user IN NUMBER) RETURN NUMBER;
    FUNCTION nr_comenzi(p_id_user IN NUMBER) RETURN NUMBER;
END magazin_pck;
/

CREATE OR REPLACE PACKAGE BODY magazin_pck AS
    FUNCTION suma_totala_comenzi(p_id_user IN NUMBER) RETURN NUMBER IS
        val_totala NUMBER := 0;
    BEGIN
        SELECT SUM(ol.price * ol.quantity) INTO val_totala FROM order_lines ol
        JOIN orders o ON ol.id_order = o.id_order
        WHERE o.id_user = p_id_user;

        RETURN val_totala;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN 0;
        WHEN OT HERS THEN RETURN 0;
    END suma_totala_comenzi;

    FUNCTION nr_comenzi(p_id_user IN NUMBER) RETURN NUMBER IS
        v_order_count NUMBER := 0;
    BEGIN
        SELECT COUNT(DISTINCT o.id_order) INTO v_order_count FROM orders o
        WHERE o.id_user = p_id_user;

        RETURN v_order_count;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN 0;
        WHEN OTHERS THEN RETURN 0;
    END nr_comenzi;
END magazin_pck;
/

--Declan?atori

--1.	S? se creeze 2 declan?atori. Unul înainte de efectuarea unui update asupra stocului unui produs iar cel?lalt dup?. Ace?tia vor afi?a stocul produsului înainte, respectiv dup? modificare.

CREATE OR REPLACE TRIGGER before_update_stock
BEFORE UPDATE OF stock ON products
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Stocul produsului cu ID-ul ' || :OLD.id_product || ' înainte de modificare: ' || :OLD.stock);
END before_update_stock;
/

CREATE OR REPLACE TRIGGER after_update_stock
AFTER UPDATE OF stock ON products
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Stocul produsului cu ID-ul ' || :NEW.id_product || ' dup? modificare: ' || :NEW.stock);
END after_update_stock;
/

DECLARE
v_stoc number;
BEGIN
    v_stoc:=142;

    UPDATE products
    SET stock=v_stoc
    Where id_product=11;
END;



