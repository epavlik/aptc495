/* Elizabeth Pavlik
   CMSC 420 Project 4
   10 December 2024
*/

/* Drop procedures */
DROP PROCEDURE populate_sales_facts;

/* Drop existing tables if present */
DROP TABLE sales_facts CASCADE CONSTRAINTS;
DROP TABLE sales_financings CASCADE CONSTRAINTS;
DROP TABLE sales CASCADE CONSTRAINTS;
DROP TABLE times;
DROP TABLE vehicles;
DROP SEQUENCE vehicle_code_seq;
DROP TABLE dealerships;
DROP TABLE salespersons;
DROP TABLE financing_plans;
DROP TABLE oltp_vehicles;
DROP TABLE customers;

/******************** Project 1-3 Code ********************/

/********************* TABLE CREATION *********************/

/* Create 'customers' Table */
CREATE TABLE customers (
    cust_ID        NUMBER GENERATED ALWAYS AS IDENTITY
                   (START WITH 1001 INCREMENT BY 1),
    first_name     VARCHAR2(50)    NOT NULL,
    middle_initial VARCHAR2(1)             ,
    last_name      VARCHAR2(50)    NOT NULL,
    street_address VARCHAR2(50)    NOT NULL,
    city           VARCHAR2(50)    NOT NULL,
    us_state       VARCHAR2(2)     NOT NULL,
    zip_code       VARCHAR2(10)    NOT NULL
);

/* Primary Key Constraint on cust_ID */
ALTER TABLE customers
    ADD CONSTRAINT pk_cust_ID PRIMARY KEY (cust_ID);

/* Create 'oltp_vehicles' Table */
CREATE TABLE oltp_vehicles (
    VIN            VARCHAR2(17)    NOT NULL,
    vehicle_type   VARCHAR2(20)    NOT NULL,
    vehicle_make   VARCHAR2(50)    NOT NULL,
    vehicle_model  VARCHAR2(50)    NOT NULL,
    wherefrom      VARCHAR2(50)    NOT NULL,
    wholesale_cost NUMBER(6)       NOT NULL
); -- originally 'vehicles'

/* Primary Key Constraint on VIN,
   Positive Int Check Constraint on wholesale_cost */
ALTER TABLE oltp_vehicles
    ADD (
        CONSTRAINT pk_VIN PRIMARY KEY (VIN),
        CONSTRAINT chk_sale_cost CHECK (wholesale_cost > 0)
    );

/* Create 'financing_plans' Table */
CREATE TABLE financing_plans (
    plan_ID         NUMBER GENERATED ALWAYS AS IDENTITY
                    (START WITH 1001 INCREMENT BY 1), -- aka 'Plan_Code'
    institution     VARCHAR(30)     NOT NULL,
    loan_type       VARCHAR(20)     NOT NULL,
    min_down        NUMBER(6)       NOT NULL,
    max_loan_amt    NUMBER(6)       NOT NULL,
    max_term        NUMBER(2)       NOT NULL, -- months
    loan_APR        NUMBER(4,4)     NOT NULL  -- aka 'Loan_Perc_Rate'
);

/* Add Primary Key Constraint on plan_ID,
   Add Positive Int Checks on min_down, max_loan_amt, max_term,
   Add Fractional Check on loan_APR */
ALTER TABLE financing_plans
    ADD (
        CONSTRAINT pk_plan_ID PRIMARY KEY (plan_ID),
        CONSTRAINT chk_min_down CHECK (min_down >= 0),
        CONSTRAINT chk_max_loan_amt CHECK (max_loan_amt > 0),
        CONSTRAINT chk_max_term CHECK (max_term > 0),
        CONSTRAINT chk_loan_APR CHECK (loan_APR > 0 AND loan_APR < 1)
    );

/* Create 'salespersons' Table */
CREATE TABLE salespersons (
    salesperson_ID NUMBER GENERATED ALWAYS AS IDENTITY
                   (START WITH 1001 INCREMENT BY 1),
    dealer_ID      NUMBER                  ,
    title          VARCHAR2(25)    NOT NULL,
    first_name     VARCHAR2(50)    NOT NULL,
    middle_initial VARCHAR2(1)             ,
    last_name      VARCHAR2(50)    NOT NULL,
    hire_date      DATE            NOT NULL
);

/* Add Primary Key Constraint on salesperson_ID */
ALTER TABLE salespersons
    ADD CONSTRAINT pk_salesperson_ID PRIMARY KEY (salesperson_ID);

/* Create 'sales' Table */
CREATE TABLE sales (
    sale_ID          NUMBER GENERATED ALWAYS AS IDENTITY
                     (START WITH 1001 INCREMENT BY 1),
    cust_ID          NUMBER         NOT NULL,
    VIN              VARCHAR2(17)   NOT NULL,
    sale_date        DATE           NOT NULL,
    mileage          NUMBER(6)      NOT NULL,
    vehicle_status   VARCHAR2(5)    NOT NULL,
    gross_sale_price NUMBER(6)      NOT NULL
);

/* Add Primary Key Constraint on sale_ID,
   Add Foreign Key Constraint on cust_ID, VIN,
   Add Positive Int Check Constraint on gross_sale_price */
ALTER TABLE sales
    ADD (
        CONSTRAINT pk_sale_ID PRIMARY KEY (sale_ID),
        CONSTRAINT fk_cust_ID FOREIGN KEY (cust_ID)
            REFERENCES customers (cust_ID)
            ON DELETE CASCADE,
        CONSTRAINT fk_oltp_VIN FOREIGN KEY (VIN)
            REFERENCES oltp_vehicles (VIN)
            ON DELETE CASCADE,
        CONSTRAINT chk_sale_price CHECK (gross_sale_price > 0)
    );

/* Create 'sales_financings' table */
CREATE TABLE sales_financings (
    sale_ID        NUMBER          NOT NULL,
    plan_ID        NUMBER          NOT NULL,
    down_pay       NUMBER(6)       NOT NULL,
    loan_term      NUMBER(2)       NOT NULL
);

/* Primary key constraint on sale_ID and plan_ID
   Foreign key constraints on sale_ID and plan_ID
   Positive integer check on down_pay */
ALTER TABLE sales_financings
    ADD (
        CONSTRAINT pk_sales_financings PRIMARY KEY (sale_ID, plan_ID),
        CONSTRAINT fk_sf_sale_ID FOREIGN KEY (sale_ID)
            REFERENCES sales (sale_ID)
            ON DELETE CASCADE,
        CONSTRAINT fk_sf_plan_ID FOREIGN KEY (plan_ID)
            REFERENCES financing_plans (plan_ID)
            ON DELETE CASCADE,
        CONSTRAINT chk_downpay_pos CHECK (down_pay >= 0)
    );

/***************** OLTP TABLE POPULATION ******************/

/* Populate 'customers' Table (125 Rows) */
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Mary', 'L', 'Davis', '7400 Lindbergh Dr', 'Gaithersburg', 'MD', '20879-5408');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
    VALUES ('Ning', 'Yuan', '5475 Sheffield Ct', 'Alexandria', 'VA', '22311-5475');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Chloe', 'O', 'Davis', '1 Southerly Ln', 'Charles Town', 'WV', '25414-4098');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Steven', 'S', 'Russell', '3066 Benjamin Ct', 'Fort George G Meade', 'MD', '20755-1952');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Olivia', 'G', 'Martinez', '4701 Queens Chapel Ter', 'Washington', 'DC', '20017-3138');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('David', 'F', 'Garcia', '14901 Stratford Estates Dr', 'Upper Marlboro', 'MD', '20772-7727');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
    VALUES ('Nicoletta', 'Nucci', '101 River Rd', 'Farmville', 'VA', '23901-3932');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Walter', 'D', 'Ivy', '1499 Massachusetts Ave', 'Washington', 'DC', '20005-2854');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Misty', 'A', 'Piper', '9461 Muirkirk Rd', 'Laurel', 'MD', '20708-2790');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Dale', 'S', 'Wallace', '3835 9th St N', 'Arlington', 'VA', '22203-1998');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Melissa', 'C', 'Phillips', '3500 Winchester Ave', 'Martinsburg', 'WV', '25405-2454');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Andrew', 'D', 'Lui', '400 Excaliber Cir', 'Fredericksburg', 'VA', '22406-6485');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
    VALUES ('Grazyna', 'Chmielewska', '818 18th St', 'Washington', 'DC', '20006-3533');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Michael', 'J', 'King', '2054 Quaker Way', 'Annapolis', 'MD', '21401-8155');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
    VALUES ('Claudette', 'M', 'Soliz Velasquez', '12454 Everest Peak Ln', 'Woodbridge', 'VA', '22192-6733');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Brielle', 'J', 'McKay', '7162 Mahogany Dr', 'Hyattsville', 'MD', '20785-5803');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Joey', 'A', 'Russell', '2607 Jasper St', 'Washington', 'DC', '20020-2032');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Raelynn', 'R', 'Hinton', '3900 Kane Gap Rd', 'Duffield', 'VA', '24244-8096');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Frankie', 'S', 'Holland', '10501 Wicomico Ridge Rd', 'Charlotte Hall', 'MD', '20622-3702');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Mariah', 'C', 'Kent', '1934 11th St', 'Washington', 'DC', '20001-4986');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Mekhi', 'R', 'Greer', '14000 Prices Bridge Rd', 'Glade Spring', 'VA', '24340-4522');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Reina', 'K', 'Chung', '200 Main St Ext', 'Accident', 'MD', '21520-2068');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Ira', 'E', 'Copeland', '601 Salem Hwy', 'Stuart', 'VA', '24171-4663');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Dayana', 'G', 'Donovan', '470 Lenfant Plz', 'Washington', 'DC', '20026-7512');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Brayan', 'McIntyre', '1100 Pennsylvania Ave', 'Baltimore', 'MD', '21201-6700');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Rebekah', 'A', 'Ventura', '601 13th St', 'Washington', 'DC', '20005-3881');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Branson', 'B', 'Buckley', '1021 W Main St', 'Crisfield', 'MD', '21817-1070');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Theodora', 'L', 'Kane', '803 Blakely Ct', 'Frederick', 'MD', '21702-4677');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Brock', 'K', 'Herman', '1390 Cranes Bill Way', 'Woodbridge', 'VA', '22191-5502');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Paulina', 'A', 'Levy', '1800 K St', 'Washington', 'DC', '20006-2294');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Harold', 'B', 'Jaramillo', '5231 Haras Pl', 'Fort Washington', 'MD', '20744-3808');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Guadalupe', 'Cano', '1901 Ridgehill Ave', 'Baltimore', 'MD', '21217-1238');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Terry', 'P', 'Foster', '1100 Grace Rd', 'Honaker', 'VA', '24260-4132');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Brielle', 'R', 'Simmons', '1728 W St', 'Washington', 'DC', '20020-4233');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Harrison', 'O', 'Saunders', '19800 National Hwy', 'Frostburg', 'MD', '21532-3138');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Meadow', 'K', 'Pierce', '11100 Meadowlark Ln', 'Spotsylvania', 'VA', '22553-7723');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Nicolas', 'G', 'Zavala', '5960 Westchester Park Dr', 'College Park', 'MD', '20740-2811');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Liv', 'T', 'Trevino', '12901 Keverton Dr', 'Upper Marlboro', 'MD', '20774-1836');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Jaime', 'O', 'Horton', '18500 Grouse Ln', 'Gaithersburg', 'MD', '20879-1715');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Aitana', 'L', 'Newton', '600 Allison St', 'Washington', 'DC', '20017-2213');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Santino', 'R', 'Reynolds', '1 Sixpence Ln', 'Lexington', 'VA', '24450-5727');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Isabelle', 'A', 'Chung', '1325 T St', 'Washington', 'DC', '20009-7891');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Ira', 'B', 'Hoffman', '3000 Beaver Creek Rd', 'Laurel', 'MD', '20724-2935');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Aspen', 'L', 'Washington', '3750 Virginia Beach Blvd', 'Virginia Beach', 'VA', '23452-3411');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Juan', 'K', 'Armstrong', '1301 Woolly Way', 'Crownsville', 'MD', '21032-1435');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Presley', 'Hoover', '39062 Carlton Way', 'Mechanicsville', 'MD', '20659-3266');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Jaziel', 'W', 'Lamb', '6200 Oregon Ave', 'Washington', 'DC', '20015-1541');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Amaia', 'R', 'Chambers', '301 Greenspring Valley Rd', 'Owings Mills', 'MD', '21117-4322');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Orion', 'A', 'Mendoza', '14130 Sullyfield Cir', 'Chantilly', 'VA', '20151-1611');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Cora', 'P', 'Lee', '1 Farmer Ln', 'Galax', 'VA', '24333-2080');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Jack', 'L', 'Barrera', '5024 Silver Hill Ct', 'District Heights', 'MD', '20747-2006');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Beatrice', 'W', 'Hardin', '583 Calla Ct', 'Newport News', 'VA', '23608-1731');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Hassan', 'S', 'Medina', '5950 Piney Branch Rd', 'Washington', 'DC', '20011-7601');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Elliana', 'L', 'Powell', '3122 Guilford Ave', 'Baltimore', 'MD', '21218-3582');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Bennett', 'F', 'Pace', '17300 Kindred Rd', 'Boykins', 'VA', '23827-2122');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Giana', 'T', 'Dickerson', '8750 Georgia Ave', 'Silver Spring', 'MD', '20910-3673');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Flynn', 'Griffin', '14812 Physicians Ln', 'Rockville', 'MD', '20850-3911');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Charlie', 'W', 'Vaughn', '2 Wood Lark Ln', 'Linden', 'VA', '22642-5252');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Remy', 'G', 'Carlson', '1 South Ave', 'Harrisonburg', 'VA', '22801-2815');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Kali', 'S', 'Herring', '200 E Pratt St', 'Baltimore', 'MD', '21202-6155');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Henrik', 'M', 'Atkinson', '1099 New York Ave', 'Washington', 'DC', '20001-4453');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Jazmin', 'P', 'Kline', '5701 Linda Rd', 'Sandston', 'VA', '23150-1309');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Ramon', 'W', 'McKinney', '900 N Taylor St', 'Arlington', 'VA', '22203-1876');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Gwendolyn', 'B', 'Stevenson', '501 Chester Gap Rd', 'Chester Gap', 'VA', '22623-2138');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Callan', 'T', 'McCarthy', '1101 Wild Goose Ct', 'Westminster', 'MD', '21157-6858');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Kira', 'K', 'Lozano', '3950 Langley Ct', 'Washington', 'DC', '20016-5536');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Boone', 'T', 'Willis', '14900 Cactus Hill Rd', 'Accokeek', 'MD', '20607-9684');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Alexa', 'O', 'Grimes', '1001 Rockville Pike', 'Rockville', 'MD', '20852-1374');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Harlan', 'E', 'Hood', '4424 1st Pl', 'Washington', 'DC', '20011-4903');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Briana', 'M', 'Collins', '17501 Saddle Run', 'Rixeyville', 'VA', '22737-3254');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Miles', 'Henry', '13 Harris St', 'Dublin', 'VA', '24084-2505');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Summer', 'P', 'Fleming', '1400 Independence Ave', 'Washington', 'DC', '20250-1093');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Fernando', 'S', 'Marks', '3100 Aberfoyle Pl', 'Washington', 'DC', '20015-2326');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Monica', 'K', 'Moody', '11200 James Madison Pkwy', 'King George', 'VA', '22485-4011');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Ryland', 'T', 'Thompson', '7161 Silver Lake Blvd', 'Alexandria', 'VA', '22315-3220');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Madison', 'N', 'Owens', '601 M St', 'Washington', 'DC', '20002-3425');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Adriel', 'A', 'McDuff', '14301 Old Strother Ln', 'Culpeper', 'VA', '22701-9727');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Joanna', 'F', 'Walters', '1621 T St', 'Washington', 'DC', '20009-3302');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Colson', 'C', 'Houston', '5200 Grove Ave', 'Richmond', 'VA', '23226-1633');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Lylah', 'Fuller', '9051 Falcon Glen Ct', 'Bristow', 'VA', '20136-5737');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Andre', 'K', 'Collins', '600 4th St', 'Washington', 'DC', '20024-2884');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Kinsley', 'J', 'Wilkinson', '8510 16th St', 'Silver Spring', 'MD', '20910-5938');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Leonard', 'K', 'Clark', '1100 Big Otter Dr', 'Blue Ridge', 'VA', '24064-3038');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Chloe', 'B', 'Hayes', '15600 Otter Rd', 'Spring Grove', 'VA', '23881-8881');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Legend', 'A', 'Pierce', '604 G St', 'Washington', 'DC', '20003-2797');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Arabella', 'Valdez', '3300 Starboard St', 'Greenbackville', 'VA', '23356-2717');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Kyler', 'F', 'Wagner', '1401 Florida Ave', 'Washington', 'DC', '20002-5007');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Maeve', 'N', 'Fitzpatrick', '3701 27th St', 'Chesapeake Beach', 'MD', '20732-9387');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Blaze', 'S', 'Wolf', '300 Conley Pond Rd', 'Warsaw', 'VA', '22572-3931');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Jolene', 'M', 'Richard', '101 Old Barn Rd', 'Penhook', 'VA', '24137-2160');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Ahmed', 'F', 'Love', '1000 Douglas St', 'Washington', 'DC', '20018-1720');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Avianna', 'N', 'Burgess', '7401 Smallwood Dr', 'Oxon Hill', 'MD', '20745-1752');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Kolton', 'D', 'Nixon', '3 Hampton Ct', 'Bryans Road', 'MD', '20616-6086');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Deborah', 'B', 'Nolan', '9601 Hoke Brady Rd', 'Henrico', 'VA', '23231-8328');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Maximo', 'O', 'Rubio', '2440 Virginia Ave', 'Washington', 'DC', '20037-4641');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Hadassah', 'T', 'Garcia', '445 Warhawks Rd', 'Chesapeake', 'VA', '23322-3872');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('James', 'L', 'Howell', '116 Catherine St', 'Salisbury', 'MD', '21801-5064');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Mckenna', 'G', 'Chase', '42 W 27th St', 'Richmond', 'VA', '23225-3962');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Otis', 'Barrett', '1 Dartmouth Dr', 'Hagerstown', 'MD', '21742-4525');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Kendall', 'A', 'Drake', '4741 S Capitol Ter', 'Washington', 'DC', '20032-2752');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Jalen', 'G', 'Donaldson', '801 Kemmer Gem Rd', 'Saint Charles', 'VA', '24282-8097');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Natasha', 'N', 'Galindo', '806 7th St', 'Washington', 'DC', '20001-3868');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Salvatore', 'R', 'Doyle', '6801 Sahalee Cir', 'Radford', 'VA', '24141-6995');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Annalise', 'F', 'Weeks', '115 5th Ave', 'Glen Burnie', 'MD', '21061-3665');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Anders', 'C', 'Fowler', '1500 Heather Hollow Cir', 'Silver Spring', 'MD', '20904-2341');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Lennon', 'J', 'Mora', '455 Massachusetts Ave', 'Washington', 'DC', '20001-2777');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Arturo', 'C', 'Elliott', '6 Whirlwind Ct', 'Windsor Mill', 'MD', '21244-1517');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Noelle', 'G', 'Owens', '12001 Beech Grove Ln', 'Lovettsville', 'VA', '20180-2352');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Riley', 'M', 'Meza', '2 Montgomery Ave', 'Gaithersburg', 'MD', '20877-2708');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Rosa', 'L', 'Lu', '616 H St', 'Washington', 'DC', '20001-5802');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Duncan', 'Knapp', '201 Boswell Rd', 'Baltimore', 'MD', '21229-3212');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Linda', 'J', 'Callahan', '9413 Columbia Blvd', 'Silver Spring', 'MD', '20910-1528');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Quinton', 'F', 'Alfaro', '900 Porter House Rd', 'Concord', 'VA', '24538-3599');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Yasmin', 'D', 'Hebert', '20100 Gunners Ter', 'Germantown', 'MD', '20876-2705');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Guillermo', 'G', 'Colon', '550 N St', 'Washington', 'DC', '20024-4567');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Remy', 'M', 'Clayton', '1101 Union Woods Dr', 'Brodnax', 'VA', '23920-3306');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Boston', 'E', 'Hernandez', '5161 River Rd', 'Bethesda', 'MD', '20816-1523');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Camila', 'K', 'Thornton', '701 Cumberland St', 'Marion', 'VA', '24354-2315');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Malik', 'F', 'Woodard', '1702 Summit Pl', 'Washington', 'DC', '20009-2934');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Aubrie', 'C', 'Miranda', '3529 14th St', 'Washington', 'DC', '20010-1382');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Rory', 'L', 'Lynn', '1500 Jacktown Rd', 'Lexington', 'VA', '24450-6200');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Samira', 'N', 'Bernard', '1822 Metzerott Rd', 'Adelphi', 'MD', '20783-5162');
INSERT INTO customers (first_name, last_name, street_address, city, us_state, zip_code)
	VALUES ('Jair', 'Bowman', '3341 22nd St', 'Washington', 'DC', '20020-2038');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Fiona', 'L', 'Trejo', '3800 Elkhorn Ave', 'Norfolk', 'VA', '23508-2242');
INSERT INTO customers (first_name, middle_initial, last_name, street_address, city, us_state, zip_code)
	VALUES ('Wesson', 'K', 'Watts', '39706 Big Chestnut Rd', 'Leonardtown', 'MD', '20650-5629');

/* Populate 'oltp_vehicles' Table (125 Rows) */
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('1HGFG12659SV7TLC2', 'SUV', 'Honda', 'CR-V', 'Arlington', 38400);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('1B3ES66S75DFE93FW', 'Full-Size Car', 'Dodge', 'Charger', 'Springfield', 44470);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('1GAHG39R2WJC6WT3J', 'Light Truck', 'Chevrolet', 'Colorado', 'Fairfax', 31095);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('1N4AA5AP0BFMFEA1Y', 'Mid-Size Car', 'Nissan', 'Altima', 'Fairfax', 27000);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('1HGES25754N2M8AE7', 'Mid-Size Car', 'Honda', 'Accord', 'Alexandria', 28295);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('2T1CF28P51ZJK59U5', 'Compact Car', 'Toyota', 'Prius', 'Washington', 32795);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('WDCYR46E748BBEX3K', 'SUV', 'Mercedes-Benz', 'GLE 350', 'College Park', 61850);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('WVWHV71K096C2PF6F', 'Compact Car', 'Volkswagen', 'Jetta', 'Fredericksburg', 30225);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('1F1NU40S64ZVJLB3S', 'Light Truck', 'Ford', 'F-150', 'Silver Spring', 36965);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('2T2BB2BA3BH9Z7N55', 'SUV', 'Lexus', 'RX 500', 'Sterling', 51550);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('5UMDU93406H6PUXZT', 'Full-Size Car', 'BMW', 'i7', 'Alexandria', 124200);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('5NMSG3FB3ARGJE8HS', 'SUV', 'Hyundai', 'Santa Fe', 'Arlington', 34200);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('1F1SU40S339AT1KAJ', 'SUV', 'Ford', 'Mustang Mach-E', 'Laurel', 56990);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
    VALUES ('1GASHCC47BHA1TK7H', 'Light Truck', 'Chevrolet', 'Silverado', 'Washington', 48000);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3GNFK16318G269795', 'SUV', 'Chevrolet', 'Suburban', 'Washington', 55458);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JH4DA9360LS010859', 'Compact Car', 'Acura', 'Integra', 'Laurel', 46683);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1B4HS28N51F547639', 'SUV', 'Dodge', 'Durango', 'Arlington', 34072);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JN8AZ1MU7AW004224', 'SUV', 'Nissan', 'Murano', 'Fredericksburg', 40329);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1GCJK33104F173427', 'Light Truck', 'Chevrolet', 'Silverado', 'Washington', 33402);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1FTEF14N5KNB30636', 'Light Truck', 'Ford', 'F-150', 'Washington', 48822);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1HGCG56582A126825', 'Mid-Size Car', 'Honda', 'Accord', 'Fredericksburg', 37896);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JT6HT00W4Y0093462', 'SUV', 'Lexus', 'LX 470', 'Laurel', 44158);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2G1WD57C491198247', 'Full-Size Car', 'Chevrolet', 'Impala', 'Springfield', 31852);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JHLRD78995C037015', 'SUV', 'Honda', 'CR-V', 'College Park', 47403);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2T1BR18E5WC056406', 'Compact Car', 'Toyota', 'Corolla', 'College Park', 55939);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1FMDU84P2YUA02375', 'SUV', 'Ford', 'Explorer', 'Springfield', 57020);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1GNKVGED5CJ196120', 'SUV', 'Chevrolet', 'Traverse', 'Sterling', 46666);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JM3ER293490222369', 'SUV', 'Mazda', 'CX-7', 'College Park', 32747);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1GNEK13T7YJ204464', 'SUV', 'Chevrolet', 'Tahoe', 'Fairfax', 38685);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2HGCA5630K0018358', 'Mid-Size Car', 'Honda', 'Accord', 'Laurel', 54734);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2FMDK4KC7BBA48439', 'SUV', 'Ford', 'Edge', 'Alexandria', 27757);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JT6HF10U3Y0133607', 'SUV', 'Lexus', 'RX 300', 'Laurel', 58942);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1HGEJ1225RL034729', 'Compact Car', 'Honda', 'Civic', 'Laurel', 44996);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3HGCM56364G702777', 'Mid-Size Car', 'Honda', 'Accord', 'Washington', 45183);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1FTFX1EF0CFA64484', 'Light Truck', 'Ford', 'F-150', 'Fairfax', 50432);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2HNYD2H32CH539683', 'SUV', 'Acura', 'MDX', 'College Park', 43256);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JF1GPAA63G9203107', 'Compact Car', 'Subaru', 'Impreza', 'Alexandria', 33927);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1LNHL9DK3DG812895', 'Full-Size Car', 'Lincoln', 'MKS', 'Alexandria', 35191);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1GYS4TKJ2FR708611', 'SUV', 'Cadillac', 'Escalade', 'Alexandria', 26242);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1C4NJRCBXFD417549', 'SUV', 'Jeep', 'Patriot', 'Alexandria', 51010);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1FAHP31373W9NGZNC', 'SUV', 'Ford', 'Mustang Mach-E', 'Arlington', 32684);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2G1F93D33E9135324', 'Mid-Size Car', 'Chevrolet', 'Camaro', 'Laurel', 44998);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('KNAFZ5A35G5536829', 'Compact Car', 'Kia', 'Forte', 'Fredericksburg', 58991);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2T2HK31U086C07826', 'SUV', 'Lexus', 'RX 350', 'College Park', 43783);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3VWWJ71K06M666892', 'Compact Car', 'Volkswagen', 'Jetta', 'Sterling', 26600);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JN1CV6EP0A0013908', 'Compact Car', 'Infiniti', 'G37', 'Alexandria', 57942);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JTJBT20X730262852', 'SUV', 'Lexus', 'GX 470', 'Washington', 30366);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3D4PG6FD0BT273410', 'SUV', 'Dodge', 'Journey', 'Fairfax', 48040);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JH4KC1F50GC000287', 'Mid-Size Car', 'Acura', 'RLX', 'Laurel', 39496);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('KNAFW4A30C5544771', 'Compact Car', 'Kia', 'Forte', 'College Park', 38517);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2B3KA73W76H369233', 'Mid-Size Car', 'Dodge', 'Charger', 'Springfield', 51885);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1FAHP2E97EG161175', 'Mid-Size Car', 'Ford', 'Taurus', 'Laurel', 41346);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2G1FT1DW0B0011446', 'Mid-Size Car', 'Chevrolet', 'Camaro', 'College Park', 51637);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JTJJM7FX2F152DJ88', 'SUV', 'Lexus', 'GX 460', 'Laurel', 50509);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5FNYF4H95DB502408', 'SUV', 'Honda', 'Pilot', 'Alexandria', 27538);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3LNHL2GL5AR634441', 'Mid-Size Car', 'Lincoln', 'MKZ', 'Springfield', 44740);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('WBA6A0C51DDZ03641', 'Full-Size Car', 'BMW', '640i', 'Alexandria', 55906);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JB3BD4370CY403965', 'Mid-Size Car', 'Dodge', 'Challenger', 'Arlington', 39493);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JN1GB22S4KU512197', 'Compact Car', 'Nissan', 'Sentra', 'Silver Spring', 33251);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JTHBF5C28C119CS85', 'Mid-Size Car', 'Lexus', 'IS 250', 'Fredericksburg', 30890);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3VWEF81K27M066072', 'Compact Car', 'Volkswagen', 'Jetta', 'Laurel', 28811);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JT8BF28G910662664', 'Mid-Size Car', 'Lexus', 'ES 300', 'Arlington', 42110);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2HNYD18204H501789', 'SUV', 'Acura', 'MDX', 'Arlington', 28774);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JTJBT20X050095298', 'SUV', 'Lexus', 'GX 470', 'College Park', 45789);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1GC1KUE83FF546236', 'Light Truck', 'Chevrolet', 'Silverado', 'Fredericksburg', 41749);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('KMHJF31M3RU510043', 'Compact Car', 'Hyundai', 'Elantra', 'Sterling', 41096);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1ZVBP8AM2B5843530', 'Mid-Size Car', 'Ford', 'Mustang', 'Laurel', 47367);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1HGCD7154SA800139', 'Mid-Size Car', 'Honda', 'Accord', 'College Park', 54594);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2G61R5S38E9326241', 'Full-Size Car', 'Cadillac', 'XTS', 'Silver Spring', 58593);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('WAUWGBFC7EN115284', 'Full-Size Car', 'Audi', 'A7', 'College Park', 59257);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1B7HF13Z0TJ147404', 'Light Truck', 'Dodge', 'Ram 1500', 'Fredericksburg', 31919);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2C3CDXAT0EH221348', 'Mid-Size Car', 'Dodge', 'Charger', 'Arlington', 32252);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3FAFP4BE0E0012611', 'Compact Car', 'Ford', 'Fiesta', 'Arlington', 28382);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JM1DKBD70G0104500', 'SUV', 'Mazda', 'CX-3', 'Fredericksburg', 26461);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('KNAJC526575661849', 'SUV', 'Kia', 'Sorento', 'Silver Spring', 35022);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2FDDX14G0C0017446', 'Light Truck', 'Ford', 'F-150', 'Laurel', 38021);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('WVWAA7AJ8AW282758', 'Compact Car', 'Volkswagen', 'Golf', 'Laurel', 30447);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('KMHJF25F6X4856431', 'Compact Car', 'Hyundai', 'Elantra', 'Laurel', 30410);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JTHBL5EF0F5134673', 'Full-Size Car', 'Lexus', 'LS 460', 'Sterling', 51023);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5GALRAED0AJ104442', 'SUV', 'Buick', 'Enclave', 'College Park', 28352);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5LMEU27AX1LJ01480', 'SUV', 'Lincoln', 'Navigator', 'Springfield', 41181);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1N4AL11E62C147104', 'Mid-Size Car', 'Nissan', 'Altima', 'Alexandria', 39751);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1GNKREED4FJ240797', 'SUV', 'Chevrolet', 'Traverse', 'Washington', 56572);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1FTEX1E87AFC48685', 'Light Truck', 'Ford', 'F-150', 'Laurel', 34471);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JF2SHACC0CH417364', 'SUV', 'Subaru', 'Forester', 'Fairfax', 49629);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1FALP6738WUGJ6SRS', 'SUV', 'Ford', 'Expedition', 'College Park', 41486);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5N1AL0MM8EL549388', 'SUV', 'Infiniti', 'JX35', 'Springfield', 54953);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1HGCG3248YA800580', 'Mid-Size Car', 'Honda', 'Accord', 'College Park', 46498);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1J4HG58N070010169', 'SUV', 'Jeep', 'Commander', 'Springfield', 34886);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('WA1WGAFP0EA060954', 'SUV', 'Audi', 'Q5', 'Washington', 50402);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5J8TB3H50DL001826', 'SUV', 'Acura', 'RDX', 'Alexandria', 46498);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1GC2CYC8XCZ295415', 'Light Truck', 'Chevrolet', 'Silverado', 'Alexandria', 51645);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JH4C42F64AC007167', 'Compact Car', 'Acura', 'TSX', 'Springfield', 37336);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5N1AR1NB7CC562261', 'SUV', 'Nissan', 'Pathfinder', 'Silver Spring', 52041);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2HKRM4H90CH100368', 'SUV', 'Honda', 'CR-V', 'Arlington', 30538);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('WBAXG5C53CD191308', 'Full-Size Car', 'BMW', '530i', 'Washington', 50942);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('KM8SC13E054010942', 'SUV', 'Hyundai', 'Santa Fe', 'Washington', 39560);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('4S4BRDAC7D2319125', 'SUV', 'Subaru', 'Outback', 'College Park', 56332);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1FAHP34P73W170323', 'Compact Car', 'Ford', 'Focus', 'Alexandria', 58120);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('KL4CJCSB7DB069654', 'SUV', 'Buick', 'Encore', 'Washington', 36822);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2G1WT57KX91325982', 'Full-Size Car', 'Chevrolet', 'Impala', 'Sterling', 34916);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('KNDPC3AC9E7618772', 'SUV', 'Kia', 'Sportage', 'College Park', 54362);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('WVWNA63BXXE516494', 'Mid-Size Car', 'Volkswagen', 'Passat', 'Silver Spring', 25667);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3C4PDCGG3FT506554', 'SUV', 'Dodge', 'Journey', 'Fredericksburg', 40162);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5XYZKDAG4CG4CG101', 'SUV', 'Hyundai', 'Santa Fe', 'College Park', 49687);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JM3KE2BE6D0532395', 'SUV', 'Mazda', 'CX-5', 'Springfield', 32455);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1G11E5RA0D0016986', 'Mid-Size Car', 'Chevrolet', 'Malibu', 'Springfield', 26515);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2HNYB1H40BH000129', 'SUV', 'Acura', 'ZDX', 'Silver Spring', 48758);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JN1CV6FH0A0017612', 'Compact Car', 'Infiniti', 'G37', 'Alexandria', 44229);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JHMGD17634S400209', 'Compact Car', 'Honda', 'Fit', 'Fredericksburg', 42025);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1GYS4AEF6CR315279', 'SUV', 'Cadillac', 'Escalade', 'Alexandria', 42486);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('1C4RJFCT6FC611431', 'SUV', 'Jeep', 'Grand Cherokee', 'Silver Spring', 39755);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5YJSA1CP4CFP02607', 'Full-Size Car', 'Tesla', 'Model S', 'Washington', 59539);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JM3TB2DA5E0427307', 'SUV', 'Mazda', 'CX-9', 'Laurel', 38624);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('KMHCF24F2WA098176', 'Mid-Size Car', 'Hyundai', 'Sonata', 'Washington', 51728);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('JN1CA21D0XT721308', 'Full-Size Car', 'Nissan', 'Maxima', 'Sterling', 48478);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5XYKTDA63CG197836', 'SUV', 'Kia', 'Sorento', 'Springfield', 38475);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5YJSA1CN0CFP02439', 'Full-Size Car', 'Tesla', 'Model S', 'Washington', 50994);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3C6JD6CT1CG266927', 'Light Truck', 'Dodge', 'Ram 1500', 'Alexandria', 59430);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('3GCEC16R0V0013724', 'SUV', 'Chevrolet', 'Suburban', 'Alexandria', 36671);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2HGFG3B47EH070557', 'Compact Car', 'Honda', 'Civic', 'Laurel', 51765);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('5YJSA1CN0DFP13393', 'Full-Size Car', 'Tesla', 'Model S', 'College Park', 58693);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('WBA3B3G56DNR81337', 'Compact Car', 'BMW', '328i', 'Silver Spring', 49377);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('2G4GZ5GV7B90061EX', 'Mid-Size Car', 'Buick', 'Regal', 'Fredericksburg', 29611);
INSERT INTO oltp_vehicles (VIN, vehicle_type, vehicle_make, vehicle_model, wherefrom, wholesale_cost)
	VALUES ('4T1BE46KX9U534098', 'Mid-Size Car', 'Toyota', 'Camry', 'Alexandria', 49076);

/* Populate 'financing_plans' Table (5 Rows) */
INSERT INTO financing_plans (institution, loan_type, min_down, max_loan_amt, max_term, loan_APR)
   VALUES ('Bank of America', 'Direct Secured', 5000, 125000, 84, .0549);
INSERT INTO financing_plans (institution, loan_type, min_down, max_loan_amt, max_term, loan_APR)
   VALUES ('Truist', 'Direct Unsecured', 0, 80000, 72, .0799);
INSERT INTO financing_plans (institution, loan_type, min_down, max_loan_amt, max_term, loan_APR)
   VALUES ('Chase Auto', 'Indirect Secured', 4000, 72000, 60, .0699);
INSERT INTO financing_plans (institution, loan_type, min_down, max_loan_amt, max_term, loan_APR)
   VALUES ('Westlake Financial Services', 'Indirect Unsecured', 500, 70000, 72, .1199);
INSERT INTO financing_plans (institution, loan_type, min_down, max_loan_amt, max_term, loan_APR)
   VALUES ('Online Vehicle Sales', 'Special Finance', 0, 30000, 60, .2199);

/* Populate 'salespersons' Table (10 Rows)*/
INSERT INTO salespersons (title, first_name, middle_initial, last_name, hire_date)
    VALUES ('Sales Manager', 'Mariam', 'B', 'Glover', TO_DATE('2022-07-18', 'YYYY-MM-DD'));
INSERT INTO salespersons (title, first_name, middle_initial, last_name, hire_date)
    VALUES ('Senior Sales Associate', 'Hector', 'F', 'Zavala', TO_DATE('2022-07-29', 'YYYY-MM-DD'));
INSERT INTO salespersons (title, first_name, middle_initial, last_name, hire_date)
    VALUES ('Sales Associate I', 'Amanda', 'G', 'Christensen', TO_DATE('2022-08-09', 'YYYY-MM-DD'));
INSERT INTO salespersons (title, first_name, middle_initial, last_name, hire_date)
    VALUES ('Sales Associate II', 'Eric', 'B', 'Stein', TO_DATE('2022-08-26', 'YYYY-MM-DD'));
INSERT INTO salespersons (title, first_name, middle_initial, last_name, hire_date)
    VALUES ('Sales Associate I', 'Phoebe', 'H', 'Lim', TO_DATE('2022-10-05', 'YYYY-MM-DD'));
INSERT INTO salespersons (title, first_name, middle_initial, last_name, hire_date)
    VALUES ('Senior Sales Associate', 'Jabari', 'T', 'Boyle', TO_DATE('2022-11-08', 'YYYY-MM-DD'));
INSERT INTO salespersons (title, first_name, last_name, hire_date)
    VALUES ('Sales Associate I', 'Thuy', 'Truong', TO_DATE('2022-11-11', 'YYYY-MM-DD'));
INSERT INTO salespersons (title, first_name, middle_initial, last_name, hire_date)
    VALUES ('Sales Associate II', 'Jordan', 'L', 'Moseley', TO_DATE('2022-12-20', 'YYYY-MM-DD'));
INSERT INTO salespersons (title, first_name, middle_initial, last_name, hire_date)
    VALUES ('Sales Associate II', 'Jenna', 'M', 'Holt', TO_DATE('2023-02-28', 'YYYY-MM-DD'));
INSERT INTO salespersons (title, first_name, middle_initial, last_name, hire_date)
    VALUES ('Sales Associate I', 'Albert', 'G', 'Villarreal', TO_DATE('2023-06-21', 'YYYY-MM-DD'));

/* Populate 'sales' Table (200 Rows) */
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1002, '2T2BB2BA3BH9Z7N55', TO_DATE('2023-12-12', 'YYYY-MM-DD'), 173, 'New', 48973);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1015, 'WDCYR46E748BBEX3K', TO_DATE('2023-12-15', 'YYYY-MM-DD'), 70, 'New', 58758);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1012, '1F1NU40S64ZVJLB3S', TO_DATE('2023-12-16', 'YYYY-MM-DD'), 95, 'New', 35117);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1004, '1B3ES66S75DFE93FW', TO_DATE('2023-12-17', 'YYYY-MM-DD'), 68352, 'Used', 8300);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1010, '1GASHCC47BHA1TK7H', TO_DATE('2023-12-17', 'YYYY-MM-DD'), 25262, 'Used', 29000);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1008, '1F1SU40S339AT1KAJ', TO_DATE('2023-12-18', 'YYYY-MM-DD'), 151, 'New', 54140);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1006, '1HGFG12659SV7TLC2', TO_DATE('2023-12-18', 'YYYY-MM-DD'), 18090, 'Used', 15998);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1013, '2T1CF28P51ZJK59U5', TO_DATE('2023-12-24', 'YYYY-MM-DD'), 21572, 'Used', 19998);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1007, '1GAHG39R2WJC6WT3J', TO_DATE('2023-12-25', 'YYYY-MM-DD'), 63074, 'Used', 22998);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1005, '5UMDU93406H6PUXZT', TO_DATE('2023-12-26', 'YYYY-MM-DD'), 66, 'New', 117990);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1122, '3VWWJ71K06M666892', TO_DATE('2023-12-27', 'YYYY-MM-DD'), 644, 'New', 21280);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1085, '1FAHP2E97EG161175', TO_DATE('2023-12-29', 'YYYY-MM-DD'), 68, 'New', 33077);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1054, '1GNKVGED5CJ196120', TO_DATE('2023-12-31', 'YYYY-MM-DD'), 53, 'New', 37333);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1066, '5GALRAED0AJ104442', TO_DATE('2024-01-01', 'YYYY-MM-DD'), 44379, 'Used', 8620);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1076, '2G1F93D33E9135324', TO_DATE('2024-01-02', 'YYYY-MM-DD'), 284, 'New', 35998);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1093, '5XYZKDAG4CG4CG101', TO_DATE('2024-01-04', 'YYYY-MM-DD'), 12615, 'Used', 15087);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1115, '5LMEU27AX1LJ01480', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 247, 'New', 31945);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1038, '4S4BRDAC7D2319125', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 18, 'New', 45066);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1039, 'WBAXG5C53CD191308', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 28383, 'Used', 9051);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1101, 'JTJBT20X730262852', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 149, 'New', 24293);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1031, '1FTEF14N5KNB30636', TO_DATE('2024-01-06', 'YYYY-MM-DD'), 65535, 'Used', 12061);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1075, '1HGEJ1225RL034729', TO_DATE('2024-01-07', 'YYYY-MM-DD'), 57, 'New', 35997);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1036, 'JTHBL5EF0F5134673', TO_DATE('2024-01-07', 'YYYY-MM-DD'), 70680, 'Used', 17491);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1095, '2G1FT1DW0B0011446', TO_DATE('2024-01-08', 'YYYY-MM-DD'), 18643, 'Used', 15774);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1026, '1B7HF13Z0TJ147404', TO_DATE('2024-01-08', 'YYYY-MM-DD'), 18861, 'Used', 18842);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1123, '3HGCM56364G702777', TO_DATE('2024-01-11', 'YYYY-MM-DD'), 57624, 'Used', 6486);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1032, 'JM3ER293490222369', TO_DATE('2024-01-13', 'YYYY-MM-DD'), 92, 'New', 26198);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1048, '1B4HS28N51F547639', TO_DATE('2024-01-13', 'YYYY-MM-DD'), 604, 'New', 27258);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1070, '1FMDU84P2YUA02375', TO_DATE('2024-01-14', 'YYYY-MM-DD'), 15199, 'Used', 7959);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1056, '1GC1KUE83FF546236', TO_DATE('2024-01-17', 'YYYY-MM-DD'), 61369, 'Used', 9450);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1077, 'JF1GPAA63G9203107', TO_DATE('2024-01-18', 'YYYY-MM-DD'), 153, 'New', 27142);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1090, 'JH4C42F64AC007167', TO_DATE('2024-01-18', 'YYYY-MM-DD'), 70, 'New', 29869);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1018, 'JN8AZ1MU7AW004224', TO_DATE('2024-01-20', 'YYYY-MM-DD'), 33605, 'Used', 9468);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1059, 'WVWAA7AJ8AW282758', TO_DATE('2024-01-20', 'YYYY-MM-DD'), 66883, 'Used', 17874);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1105, '5N1AL0MM8EL549388', TO_DATE('2024-01-20', 'YYYY-MM-DD'), 71005, 'Used', 13864);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1099, '1C4RJFCT6FC611431', TO_DATE('2024-02-01', 'YYYY-MM-DD'), 95, 'New', 31804);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1064, '1HGCG56582A126825', TO_DATE('2024-02-02', 'YYYY-MM-DD'), 25080, 'Used', 19489);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1042, '5YJSA1CN0CFP02439', TO_DATE('2024-02-07', 'YYYY-MM-DD'), 204, 'New', 40795);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1089, 'JH4DA9360LS010859', TO_DATE('2024-02-07', 'YYYY-MM-DD'), 3234, 'Used', 18508);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1009, '1GYS4AEF6CR315279', TO_DATE('2024-02-10', 'YYYY-MM-DD'), 27808, 'Used', 7469);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1025, 'KM8SC13E054010942', TO_DATE('2024-02-10', 'YYYY-MM-DD'), 41612, 'Used', 11940);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1037, 'KMHJF31M3RU510043', TO_DATE('2024-02-11', 'YYYY-MM-DD'), 61654, 'New', 32877);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1027, '5J8TB3H50DL001826', TO_DATE('2024-02-11', 'YYYY-MM-DD'), 736, 'New', 37198);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1046, '1FTEX1E87AFC48685', TO_DATE('2024-02-14', 'YYYY-MM-DD'), 334, 'New', 27577);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1047, '3GNFK16318G269795', TO_DATE('2024-02-16', 'YYYY-MM-DD'), 14840, 'Used', 14402);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1011, '2G61R5S38E9326241', TO_DATE('2024-02-18', 'YYYY-MM-DD'), 70, 'New', 46874);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1041, '1GNKREED4FJ240797', TO_DATE('2024-02-19', 'YYYY-MM-DD'), 875, 'New', 45258);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1078, 'JN1CV6EP0A0013908', TO_DATE('2024-02-21', 'YYYY-MM-DD'), 32175, 'Used', 10930);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1040, '1GC2CYC8XCZ295415', TO_DATE('2024-02-22', 'YYYY-MM-DD'), 15686, 'Used', 13068);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1113, '3VWEF81K27M066072', TO_DATE('2024-02-23', 'YYYY-MM-DD'), 6548, 'Used', 6835);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1020, 'JT8BF28G910662664', TO_DATE('2024-02-25', 'YYYY-MM-DD'), 11633, 'Used', 13186);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1121, 'JTJJM7FX2F152DJ88', TO_DATE('2024-02-25', 'YYYY-MM-DD'), 1485, 'New', 40407);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1050, '5YJSA1CP4CFP02607', TO_DATE('2024-02-26', 'YYYY-MM-DD'), 10361, 'Used', 7757);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1033, 'WAUWGBFC7EN115284', TO_DATE('2024-02-26', 'YYYY-MM-DD'), 52972, 'Used', 14580);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1053, '1LNHL9DK3DG812895', TO_DATE('2024-02-27', 'YYYY-MM-DD'), 5839, 'Used', 16093);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1117, '1FAHP31373W9NGZNC', TO_DATE('2024-02-27', 'YYYY-MM-DD'), 51950, 'Used', 7077);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1067, 'WBA3B3G56DNR81337', TO_DATE('2024-02-28', 'YYYY-MM-DD'), 94, 'New', 39502);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1058, '3GCEC16R0V0013724', TO_DATE('2024-02-29', 'YYYY-MM-DD'), 369, 'Used', 17535);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1061, '3LNHL2GL5AR634441', TO_DATE('2024-03-01', 'YYYY-MM-DD'), 422, 'New', 35792);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1111, 'KMHCF24F2WA098176', TO_DATE('2024-03-04', 'YYYY-MM-DD'), 16876, 'Used', 16391);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1116, '1HGCG3248YA800580', TO_DATE('2024-03-05', 'YYYY-MM-DD'), 43241, 'Used', 16434);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1003, '3C6JD6CT1CG266927', TO_DATE('2024-03-06', 'YYYY-MM-DD'), 96, 'New', 47544);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1063, '2T1BR18E5WC056406', TO_DATE('2024-03-09', 'YYYY-MM-DD'), 35800, 'Used', 6451);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1084, 'JHLRD78995C037015', TO_DATE('2024-03-12', 'YYYY-MM-DD'), 106, 'New', 37922);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1023, '2B3KA73W76H369233', TO_DATE('2024-03-13', 'YYYY-MM-DD'), 35643, 'Used', 17397);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1019, 'JN1GB22S4KU512197', TO_DATE('2024-03-18', 'YYYY-MM-DD'), 23, 'New', 26601);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1088, '2G1WD57C491198247', TO_DATE('2024-03-19', 'YYYY-MM-DD'), 34355, 'Used', 10702);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1092, 'WA1WGAFP0EA060954', TO_DATE('2024-03-20', 'YYYY-MM-DD'), 37838, 'Used', 5568);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1069, '5FNYF4H95DB502408', TO_DATE('2024-03-22', 'YYYY-MM-DD'), 377, 'Used', 22030);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1102, '2G1WT57KX91325982', TO_DATE('2024-03-25', 'YYYY-MM-DD'), 62127, 'Used', 19285);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1107, 'KNAFW4A30C5544771', TO_DATE('2024-03-30', 'YYYY-MM-DD'), 25, 'Used', 30814);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1114, '1J4HG58N070010169', TO_DATE('2024-04-04', 'YYYY-MM-DD'), 98, 'New', 27909);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1094, 'JHMGD17634S400209', TO_DATE('2024-04-05', 'YYYY-MM-DD'), 611, 'New', 33620);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1108, 'KL4CJCSB7DB069654', TO_DATE('2024-04-06', 'YYYY-MM-DD'), 20347, 'Used', 10341);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1016, '5N1AR1NB7CC562261', TO_DATE('2024-04-09', 'YYYY-MM-DD'), 53933, 'Used', 16859);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1049, '1FALP6738WUGJ6SRS', TO_DATE('2024-04-17', 'YYYY-MM-DD'), 231, 'Used', 6970);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1080, 'JF2SHACC0CH417364', TO_DATE('2024-04-17', 'YYYY-MM-DD'), 11495, 'Used', 6130);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1022, 'JT6HF10U3Y0133607', TO_DATE('2024-04-19', 'YYYY-MM-DD'), 17, 'New', 47154);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1030, 'JB3BD4370CY403965', TO_DATE('2024-04-22', 'YYYY-MM-DD'), 4829, 'Used', 11319);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1112, '2G4GZ5GV7B90061EX', TO_DATE('2024-04-23', 'YYYY-MM-DD'), 6458, 'Used', 17958);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1001, 'JN1CA21D0XT721308', TO_DATE('2024-04-23', 'YYYY-MM-DD'), 916, 'New', 38782);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1043, 'JH4KC1F50GC000287', TO_DATE('2024-04-23', 'YYYY-MM-DD'), 56255, 'Used', 16184);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1073, '1FAHP34P73W170323', TO_DATE('2024-04-28', 'YYYY-MM-DD'), 333, 'New', 46496);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1055, '2FDDX14G0C0017446', TO_DATE('2024-04-28', 'YYYY-MM-DD'), 18790, 'Used', 6330);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1071, 'KNAFZ5A35G5536829', TO_DATE('2024-04-28', 'YYYY-MM-DD'), 39, 'New', 47193);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1098, '3C4PDCGG3FT506554', TO_DATE('2024-04-29', 'YYYY-MM-DD'), 31910, 'Used', 13552);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1106, '4T1BE46KX9U534098', TO_DATE('2024-04-30', 'YYYY-MM-DD'), 1856, 'Used', 10674);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1052, 'JT6HT00W4Y0093462', TO_DATE('2024-05-01', 'YYYY-MM-DD'), 820, 'New', 35326);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1051, '5YJSA1CN0DFP13393', TO_DATE('2024-05-02', 'YYYY-MM-DD'), 21162, 'Used', 10154);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1068, '2HNYD18204H501789', TO_DATE('2024-05-07', 'YYYY-MM-DD'), 43, 'New', 23019);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1086, 'KNDPC3AC9E7618772', TO_DATE('2024-05-08', 'YYYY-MM-DD'), 6793, 'Used', 9475);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1079, '5XYKTDA63CG197836', TO_DATE('2024-05-10', 'YYYY-MM-DD'), 1539, 'Used', 14196);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1125, '1G11E5RA0D0016986', TO_DATE('2024-05-12', 'YYYY-MM-DD'), 51, 'New', 21212);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1035, '2FMDK4KC7BBA48439', TO_DATE('2024-05-13', 'YYYY-MM-DD'), 63405, 'Used', 10875);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1034, 'JTJBT20X050095298', TO_DATE('2024-05-15', 'YYYY-MM-DD'), 2597, 'Used', 11265);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1072, '2HGCA5630K0018358', TO_DATE('2024-05-15', 'YYYY-MM-DD'), 11807, 'New', 43787);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1120, '1N4AL11E62C147104', TO_DATE('2024-05-17', 'YYYY-MM-DD'), 362, 'New', 31801);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1065, '1GNEK13T7YJ204464', TO_DATE('2024-05-18', 'YYYY-MM-DD'), 738, 'New', 30948);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1119, '1GCJK33104F173427', TO_DATE('2024-05-20', 'YYYY-MM-DD'), 34293, 'Used', 14429);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1029, '1HGCD7154SA800139', TO_DATE('2024-05-21', 'YYYY-MM-DD'), 6135, 'Used', 5069);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1021, '3FAFP4BE0E0012611', TO_DATE('2024-05-21', 'YYYY-MM-DD'), 53904, 'Used', 10880);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1110, '1ZVBP8AM2B5843530', TO_DATE('2024-05-22', 'YYYY-MM-DD'), 2373, 'Used', 10227);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1104, 'WBA6A0C51DDZ03641', TO_DATE('2024-05-26', 'YYYY-MM-DD'), 103, 'New', 44725);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1087, '2HNYB1H40BH000129', TO_DATE('2024-05-28', 'YYYY-MM-DD'), 23, 'New', 39006);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1083, 'JM3KE2BE6D0532395', TO_DATE('2024-05-29', 'YYYY-MM-DD'), 71528, 'Used', 12044);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1097, '2T2HK31U086C07826', TO_DATE('2024-05-29', 'YYYY-MM-DD'), 572, 'New', 35026);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1082, '1FTFX1EF0CFA64484', TO_DATE('2024-05-30', 'YYYY-MM-DD'), 899, 'New', 40346);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1091, '1GYS4TKJ2FR708611', TO_DATE('2024-06-01', 'YYYY-MM-DD'), 5021, 'Used', 16777);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1096, 'JTHBF5C28C119CS85', TO_DATE('2024-06-03', 'YYYY-MM-DD'), 75, 'Used', 11543);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1044, 'JM3TB2DA5E0427307', TO_DATE('2024-06-04', 'YYYY-MM-DD'), 15926, 'Used', 7785);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1124, 'KMHJF25F6X4856431', TO_DATE('2024-06-06', 'YYYY-MM-DD'), 33790, 'Used', 18742);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1057, 'JM1DKBD70G0104500', TO_DATE('2024-06-07', 'YYYY-MM-DD'), 21, 'New', 21169);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1045, 'JN1CV6FH0A0017612', TO_DATE('2024-06-08', 'YYYY-MM-DD'), 233, 'New', 35383);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1060, '2HKRM4H90CH100368', TO_DATE('2024-06-09', 'YYYY-MM-DD'), 1688, 'New', 24430);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1074, '2HNYD2H32CH539683', TO_DATE('2024-06-09', 'YYYY-MM-DD'), 509, 'New', 34605);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1109, '1C4NJRCBXFD417549', TO_DATE('2024-06-10', 'YYYY-MM-DD'), 66960, 'Used', 7024);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1028, '3D4PG6FD0BT273410', TO_DATE('2024-06-12', 'YYYY-MM-DD'), 51128, 'Used', 19500);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1024, '2HGFG3B47EH070557', TO_DATE('2024-06-18', 'YYYY-MM-DD'), 194, 'New', 41412);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1017, '2C3CDXAT0EH221348', TO_DATE('2024-06-21', 'YYYY-MM-DD'), 18958, 'Used', 11822);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1118, 'KNAJC526575661849', TO_DATE('2024-06-22', 'YYYY-MM-DD'), 732, 'New', 28018);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1100, 'WVWNA63BXXE516494', TO_DATE('2024-06-24', 'YYYY-MM-DD'), 69, 'New', 20534);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1081, 'WBAXG5C53CD191308', TO_DATE('2024-06-29', 'YYYY-MM-DD'), 341, 'New', 40754);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1103, '1B3ES66S75DFE93FW', TO_DATE('2024-06-30', 'YYYY-MM-DD'), 42339, 'Used', 16172);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1014, 'JN8AZ1MU7AW004224', TO_DATE('2024-07-02', 'YYYY-MM-DD'), 193, 'New', 32263);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1062, '1GNKVGED5CJ196120', TO_DATE('2024-07-02', 'YYYY-MM-DD'), 53097, 'Used', 7321);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1078, '3VWEF81K27M066072', TO_DATE('2024-07-03', 'YYYY-MM-DD'), 7145, 'Used', 13271);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1014, '5LMEU27AX1LJ01480', TO_DATE('2024-07-10', 'YYYY-MM-DD'), 82, 'New', 32945);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1119, 'KNAJC526575661849', TO_DATE('2024-07-12', 'YYYY-MM-DD'), 9655, 'Used', 9848);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1071, 'JH4C42F64AC007167', TO_DATE('2024-07-14', 'YYYY-MM-DD'), 279, 'New', 29869);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1060, '2HKRM4H90CH100368', TO_DATE('2024-07-15', 'YYYY-MM-DD'), 5872, 'Used', 11262);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1104, 'JB3BD4370CY403965', TO_DATE('2024-07-18', 'YYYY-MM-DD'), 48, 'New', 31594);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1082, '3GNFK16318G269795', TO_DATE('2024-07-21', 'YYYY-MM-DD'), 49059, 'Used', 13793);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1023, '1HGCG3248YA800580', TO_DATE('2024-07-24', 'YYYY-MM-DD'), 45099, 'Used', 6250);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1008, '5GALRAED0AJ104442', TO_DATE('2024-07-26', 'YYYY-MM-DD'), 709, 'New', 22682);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1052, '2HNYD2H32CH539683', TO_DATE('2024-07-31', 'YYYY-MM-DD'), 289, 'New', 34605);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1067, '5YJSA1CN0CFP02439', TO_DATE('2024-08-04', 'YYYY-MM-DD'), 14440, 'Used', 9593);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1030, '5YJSA1CP4CFP02607', TO_DATE('2024-08-08', 'YYYY-MM-DD'), 1682, 'New', 47631);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1021, 'JTJJM7FX2F152DJ88', TO_DATE('2024-08-11', 'YYYY-MM-DD'), 97, 'Used', 6672);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1013, '5XYKTDA63CG197836', TO_DATE('2024-08-12', 'YYYY-MM-DD'), 50261, 'Used', 16374);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1121, '3HGCM56364G702777', TO_DATE('2024-08-13', 'YYYY-MM-DD'), 2668, 'Used', 14212);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1088, '1B4HS28N51F547639', TO_DATE('2024-08-18', 'YYYY-MM-DD'), 617, 'New', 27258);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1046, '2G4GZ5GV7B90061EX', TO_DATE('2024-08-18', 'YYYY-MM-DD'), 2409, 'Used', 15701);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1028, '1LNHL9DK3DG812895', TO_DATE('2024-08-19', 'YYYY-MM-DD'), 277, 'New', 28153);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1112, '1J4HG58N070010169', TO_DATE('2024-08-20', 'YYYY-MM-DD'), 921, 'Used', 5348);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1012, '1GC1KUE83FF546236', TO_DATE('2024-08-26', 'YYYY-MM-DD'), 47557, 'Used', 15246);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1113, '3GCEC16R0V0013724', TO_DATE('2024-08-27', 'YYYY-MM-DD'), 501, 'New', 29337);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1070, '3VWWJ71K06M666892', TO_DATE('2024-08-27', 'YYYY-MM-DD'), 55, 'Used', 8640);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1083, '1FTFX1EF0CFA64484', TO_DATE('2024-08-28', 'YYYY-MM-DD'), 36, 'Used', 4405);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1076, '1HGEJ1225RL034729', TO_DATE('2024-08-29', 'YYYY-MM-DD'), 504, 'Used', 7866);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1017, '2G1FT1DW0B0011446', TO_DATE('2024-08-29', 'YYYY-MM-DD'), 896, 'New', 41310);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1004, '2G1WD57C491198247', TO_DATE('2024-09-04', 'YYYY-MM-DD'), 768, 'New', 25482);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1122, '2T2HK31U086C07826', TO_DATE('2024-09-07', 'YYYY-MM-DD'), 6949, 'Used', 7503);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1019, '4T1BE46KX9U534098', TO_DATE('2024-09-09', 'YYYY-MM-DD'), 408, 'New', 39261);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1093, 'JN1CV6EP0A0013908', TO_DATE('2024-09-13', 'YYYY-MM-DD'), 22672, 'Used', 5669);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1066, '1FALP6738WUGJ6SRS', TO_DATE('2024-09-18', 'YYYY-MM-DD'), 602, 'New', 33189);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1043, '5J8TB3H50DL001826', TO_DATE('2024-09-18', 'YYYY-MM-DD'), 829, 'Used', 3354);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1026, '5YJSA1CN0DFP13393', TO_DATE('2024-09-18', 'YYYY-MM-DD'), 30, 'New', 46954);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1091, 'WA1WGAFP0EA060954', TO_DATE('2024-09-22', 'YYYY-MM-DD'), 29705, 'Used', 18623);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1020, 'JN1CV6FH0A0017612', TO_DATE('2024-09-23', 'YYYY-MM-DD'), 3600, 'Used', 11323);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1101, 'WVWAA7AJ8AW282758', TO_DATE('2024-09-23', 'YYYY-MM-DD'), 191, 'New', 24358);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1016, 'JF2SHACC0CH417364', TO_DATE('2024-09-25', 'YYYY-MM-DD'), 27611, 'Used', 18404);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1059, 'WVWHV71K096C2PF6F', TO_DATE('2024-09-25', 'YYYY-MM-DD'), 27614, 'Used', 15269);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1062, 'KMHJF25F6X4856431', TO_DATE('2024-09-26', 'YYYY-MM-DD'), 644, 'New', 24328);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1069, 'JM3KE2BE6D0532395', TO_DATE('2024-09-28', 'YYYY-MM-DD'), 49523, 'Used', 13778);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1010, '1FMDU84P2YUA02375', TO_DATE('2024-09-29', 'YYYY-MM-DD'), 135, 'New', 45616);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1073, 'WAUWGBFC7EN115284', TO_DATE('2024-10-01', 'YYYY-MM-DD'), 23101, 'Used', 18438);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1055, 'JM3ER293490222369', TO_DATE('2024-10-03', 'YYYY-MM-DD'), 305, 'Used', 8381);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1079, '1G11E5RA0D0016986', TO_DATE('2024-10-06', 'YYYY-MM-DD'), 446, 'Used', 5462);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1048, 'JN1CA21D0XT721308', TO_DATE('2024-10-09', 'YYYY-MM-DD'), 36687, 'Used', 14067);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1068, 'JT6HT00W4Y0093462', TO_DATE('2024-10-10', 'YYYY-MM-DD'), 42549, 'Used', 9703);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1064, '2T1CF28P51ZJK59U5', TO_DATE('2024-10-11', 'YYYY-MM-DD'), 362, 'New', 26236);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1116, 'WBA3B3G56DNR81337', TO_DATE('2024-10-12', 'YYYY-MM-DD'), 60250, 'Used', 10245);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1125, 'KNDPC3AC9E7618772', TO_DATE('2024-10-13', 'YYYY-MM-DD'), 18288, 'Used', 16589);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1074, '5FNYF4H95DB502408', TO_DATE('2024-10-16', 'YYYY-MM-DD'), 667, 'New', 22030);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1095, '1GC2CYC8XCZ295415', TO_DATE('2024-10-17', 'YYYY-MM-DD'), 26039, 'Used', 5167);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1051, '1N4AL11E62C147104', TO_DATE('2024-10-20', 'YYYY-MM-DD'), 23584, 'Used', 12576);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1124, '5NMSG3FB3ARGJE8HS', TO_DATE('2024-10-23', 'YYYY-MM-DD'), 31135, 'Used', 14424);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1077, '2G1WT57KX91325982', TO_DATE('2024-10-23', 'YYYY-MM-DD'), 37306, 'Used', 12946);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1085, '5N1AL0MM8EL549388', TO_DATE('2024-10-27', 'YYYY-MM-DD'), 35245, 'Used', 7469);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1024, '2C3CDXAT0EH221348', TO_DATE('2024-10-29', 'YYYY-MM-DD'), 43909, 'Used', 14817);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1123, 'JTJBT20X730262852', TO_DATE('2024-10-30', 'YYYY-MM-DD'), 14410, 'Used', 6045);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1057, '1B7HF13Z0TJ147404', TO_DATE('2024-11-06', 'YYYY-MM-DD'), 48668, 'Used', 18457);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1042, '2T1BR18E5WC056406', TO_DATE('2024-11-06', 'YYYY-MM-DD'), 352, 'New', 44751);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1110, '2FDDX14G0C0017446', TO_DATE('2024-11-08', 'YYYY-MM-DD'), 1508, 'Used', 19515);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1027, '2HGCA5630K0018358', TO_DATE('2024-11-10', 'YYYY-MM-DD'), 47223, 'Used', 19214);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1011, 'KNAFW4A30C5544771', TO_DATE('2024-11-10', 'YYYY-MM-DD'), 1716, 'New', 30814);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1081, '1GYS4TKJ2FR708611', TO_DATE('2024-11-12', 'YYYY-MM-DD'), 28, 'New', 20994);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1041, '1GCJK33104F173427', TO_DATE('2024-11-12', 'YYYY-MM-DD'), 43, 'New', 26722);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1058, 'WDCYR46E748BBEX3K', TO_DATE('2024-11-12', 'YYYY-MM-DD'), 237, 'New', 49480);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1092, '1FAHP31373W9NGZNC', TO_DATE('2024-11-13', 'YYYY-MM-DD'), 1897, 'New', 26147);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1100, 'JTHBF5C28C119CS85', TO_DATE('2024-11-15', 'YYYY-MM-DD'), 485, 'New', 24712);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1054, '1FTEF14N5KNB30636', TO_DATE('2024-11-16', 'YYYY-MM-DD'), 68391, 'Used', 5883);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1007, '1ZVBP8AM2B5843530', TO_DATE('2024-11-21', 'YYYY-MM-DD'), 794, 'New', 37894);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1038, '2T2BB2BA3BH9Z7N55', TO_DATE('2024-11-24', 'YYYY-MM-DD'), 25398, 'Used', 16124);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1040, 'JTJBT20X050095298', TO_DATE('2024-11-28', 'YYYY-MM-DD'), 63, 'New', 36631);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1102, 'JHLRD78995C037015', TO_DATE('2024-12-03', 'YYYY-MM-DD'), 10619, 'Used', 12326);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1002, '2G1F93D33E9135324', TO_DATE('2024-12-04', 'YYYY-MM-DD'), 201, 'Used', 15124);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1061, '2HGFG3B47EH070557', TO_DATE('2024-12-05', 'YYYY-MM-DD'), 504, 'New', 41412);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1056, '3C4PDCGG3FT506554', TO_DATE('2024-12-08', 'YYYY-MM-DD'), 62353, 'Used', 8061);
INSERT INTO sales (cust_ID, VIN, sale_date, mileage, vehicle_status, gross_sale_price)
    VALUES (1072, 'KNAFZ5A35G5536829', TO_DATE('2024-12-09', 'YYYY-MM-DD'), 1895, 'New', 47193);

/* Populate 'sales_financings' Table (200 Rows) */
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1001, 1001, 12595, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1002, 1002, 6295, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1003, 1003, 12459, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1004, 1002, 5059, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1005, 1001, 5400, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1006, 1004, 15336, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1007, 1004, 1265, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1008, 1001, 13250, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1009, 1002, 19012, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1010, 1001, 23357, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1011, 1003, 15981, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1012, 1002, 5436, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1013, 1002, 12858, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1014, 1005, 4840, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1015, 1004, 6059, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1016, 1004, 14179, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1017, 1004, 17309, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1018, 1002, 22204, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1019, 1005, 8722, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1020, 1005, 5152, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1021, 1001, 5431, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1022, 1004, 3590, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1023, 1001, 9400, 84);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1024, 1002, 14992, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1025, 1002, 4284, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1026, 1002, 1000, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1027, 1002, 17027, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1028, 1001, 9191, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1029, 1004, 1500, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1030, 1002, 5000, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1031, 1001, 5000, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1032, 1004, 19545, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1033, 1004, 5772, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1034, 1004, 17192, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1035, 1005, 2452, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1036, 1001, 16610, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1037, 1005, 2300, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1038, 1003, 5429, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1039, 1001, 5000, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1040, 1002, 4412, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1041, 1004, 10747, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1042, 1002, 3268, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1043, 1001, 20719, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1044, 1005, 20895, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1045, 1005, 3900, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1046, 1004, 21419, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1047, 1002, 23883, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1048, 1001, 10043, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1049, 1004, 2200, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1050, 1004, 500, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1051, 1001, 5900, 84);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1052, 1004, 17718, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1053, 1005, 250, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1054, 1003, 11731, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1055, 1005, 10599, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1056, 1005, 5000, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1057, 1001, 18436, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1058, 1005, 10122, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1059, 1003, 8174, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1060, 1003, 5000, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1061, 1003, 6485, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1062, 1004, 7541, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1063, 1004, 700, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1064, 1004, 4364, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1065, 1002, 6140, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1066, 1003, 8434, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1067, 1002, 945, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1068, 1002, 2700, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1069, 1001, 10978, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1070, 1003, 6766, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1071, 1001, 21194, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1072, 1004, 12785, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1073, 1004, 5992, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1074, 1002, 500, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1075, 1005, 10762, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1076, 1005, 722, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1077, 1002, 500, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1078, 1001, 10966, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1079, 1001, 6019, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1080, 1004, 12883, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1081, 1004, 20003, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1082, 1004, 2500, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1083, 1003, 4724, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1084, 1004, 500, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1085, 1004, 15562, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1086, 1004, 1389, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1087, 1001, 5000, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1088, 1004, 24136, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1089, 1005, 200, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1090, 1004, 915, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1091, 1002, 8719, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1092, 1003, 4000, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1093, 1001, 20944, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1094, 1005, 704, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1095, 1002, 970, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1096, 1003, 17495, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1097, 1003, 19885, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1098, 1002, 5260, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1099, 1005, 7035, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1100, 1005, 1245, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1101, 1003, 4000, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1102, 1005, 9789, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1103, 1003, 5700, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1104, 1001, 8592, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1105, 1005, 2300, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1106, 1002, 22802, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1107, 1002, 21776, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1108, 1003, 15956, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1109, 1002, 300, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1110, 1005, 4307, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1111, 1004, 795, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1112, 1005, 1061, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1113, 1002, 12444, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1114, 1002, 3094, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1115, 1002, 22168, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1116, 1005, 2100, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1117, 1002, 731, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1118, 1004, 3019, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1119, 1003, 7258, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1120, 1005, 5718, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1121, 1004, 14678, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1122, 1001, 10060, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1123, 1001, 5500, 84);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1124, 1001, 21809, 84);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1125, 1002, 960, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1126, 1004, 720, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1127, 1004, 12670, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1128, 1002, 2700, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1129, 1001, 9629, 84);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1130, 1004, 3760, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1131, 1002, 13136, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1132, 1004, 2368, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1133, 1004, 2100, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1134, 1004, 21959, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1135, 1003, 21669, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1136, 1002, 1100, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1137, 1003, 9707, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1138, 1002, 665, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1139, 1005, 10123, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1140, 1005, 7400, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1141, 1005, 15663, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1142, 1003, 4800, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1143, 1004, 4644, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1144, 1005, 600, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1145, 1003, 6256, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1146, 1005, 810, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1147, 1002, 790, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1148, 1002, 0, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1149, 1005, 950, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1150, 1004, 9023, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1151, 1002, 930, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1152, 1002, 4065, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1153, 1004, 21519, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1154, 1005, 500, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1155, 1003, 4300, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1156, 1004, 750, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1157, 1002, 22394, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1158, 1004, 13249, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1159, 1002, 2400, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1160, 1005, 14983, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1161, 1003, 5500, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1162, 1004, 14453, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1163, 1003, 9281, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1164, 1001, 5000, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1165, 1004, 23721, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1166, 1003, 4200, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1167, 1002, 3000, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1168, 1002, 800, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1169, 1001, 11006, 84);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1170, 1004, 3452, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1171, 1003, 8918, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1172, 1004, 3200, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1173, 1003, 7270, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1174, 1003, 6706, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1175, 1002, 650, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1176, 1003, 4391, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1177, 1004, 5291, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1178, 1002, 640, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1179, 1005, 500, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1180, 1003, 12511, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1181, 1002, 3487, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1182, 1002, 4975, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1183, 1003, 6046, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1184, 1005, 17861, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1185, 1002, 5656, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1186, 1001, 8115, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1187, 1005, 8460, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1188, 1001, 5000, 84);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1189, 1002, 730, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1190, 1005, 1828, 24);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1191, 1001, 16137, 72);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1192, 1005, 1600, 12);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1193, 1001, 11703, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1194, 1005, 10478, 60);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1195, 1002, 7196, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1196, 1004, 1200, 36);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1197, 1004, 900, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1198, 1002, 15663, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1199, 1004, 500, 48);
INSERT INTO sales_financings (sale_ID, plan_ID, down_pay, loan_term)
	VALUES (1200, 1001, 21944, 60);

/******************* STAR SCHEMA TABLES *******************/

/* Create 'dealerships' Star Schema Dimension Table */
CREATE TABLE dealerships (
   dealer_ID       NUMBER GENERATED ALWAYS AS IDENTITY
                   (START WITH 101 INCREMENT BY 1),
   region_ID       NUMBER(3)       NOT NULL,
   district_ID     NUMBER(3)       NOT NULL,
   dealer_location VARCHAR2(30)    NOT NULL,
   street_address  VARCHAR2(50)    NOT NULL,
   city            VARCHAR2(50)    NOT NULL,
   us_state        VARCHAR2(2)     NOT NULL,
   zip_code        VARCHAR2(5)     NOT NULL,
   phone_number    VARCHAR2(12)    NOT NULL,
   sq_ft           NUMBER(5)       NOT NULL,
   opened_date     DATE            NOT NULL,
   manager         VARCHAR2(20)    NOT NULL
);

/* Primary Key Constraint on dealer_ID */
ALTER TABLE dealerships
   ADD CONSTRAINT pk_dealer_ID PRIMARY KEY (dealer_ID);

/* Populate 'dealerships' Table (10 Rows) */
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (202, 303, 'Alexandria', '4689 Lawman Ave', 'Alexandria', 'VA', '22310', '703-213-7647', 23219, TO_DATE('2018-07-19', 'YYYY-MM-DD'), 'Frank Patterson');
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (202, 302, 'Arlington', '1052 Forest Dr', 'Arlington', 'VA', '22206', '703-931-3443', 24919, TO_DATE('2018-01-11', 'YYYY-MM-DD'), 'Adrianne Jackson');
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (203, 305, 'College Park', '3273 Cost Ave', 'College Park', 'MD', '20741', '301-446-3733', 27957, TO_DATE('2018-10-16', 'YYYY-MM-DD'), 'Judith Escobar');
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (204, 307, 'Fairfax', '2832 Dorr Ave', 'Fairfax', 'VA', '22031', '703-698-0113', 21634, TO_DATE('2019-09-18', 'YYYY-MM-DD'), 'Dixie Webb');
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (206, 310, 'Fredericksburg', '813 Caroline St', 'Fredericksburg', 'VA', '22401', '540-899-0969', 29695, TO_DATE('2022-04-05', 'YYYY-MM-DD'), 'Michael Ely');
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (205, 308, 'Laurel', '3304 Cambridge Pl', 'Laurel', 'MD', '20707', '410-589-4326', 17170, TO_DATE('2020-01-02', 'YYYY-MM-DD'), 'Nathan McFadden');
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (203, 304, 'Silver Spring', '154 Doe Meadow Dr', 'Silver Spring', 'MD', '20904', '301-536-5232', 19371, TO_DATE('2018-08-03', 'YYYY-MM-DD'), 'Deborah Wood');
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (204, 306, 'Springfield', '8344 Traford Ln', 'Springfield', 'VA', '22152', '703-451-2867', 15931, TO_DATE('2019-08-13', 'YYYY-MM-DD'), 'Lorna Fitts');
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (204, 309, 'Sterling', '4188 Ashford Dr', 'Sterling', 'VA', '20166', '703-652-5840', 22157, TO_DATE('2021-06-09', 'YYYY-MM-DD'), 'Juan Sanchez');
INSERT INTO dealerships (region_ID, district_ID, dealer_location, street_address, city, us_state, zip_code, phone_number, sq_ft, opened_date, manager)
   VALUES (201, 301, 'Washington', '252 Rhode Island Ave', 'Washington', 'DC', '20004', '202-324-8143', 18308, TO_DATE('2017-06-14', 'YYYY-MM-DD'), 'Nancy Rossi');

/* Create 'vehicles' Star Schema Dimension Table */
CREATE TABLE vehicles (
   vehicle_code        NUMBER        NOT NULL,
   vehicle_description VARCHAR2(100) NOT NULL -- avoids possible 'description' keyword reference
);

ALTER TABLE vehicles
    ADD CONSTRAINT pk_vehicle_code PRIMARY KEY (vehicle_code);

/* Populate vehicles.vehicle_code Using Sequence */
CREATE SEQUENCE vehicle_code_seq
   START WITH 2001
   INCREMENT BY 1
   NOCACHE;

/* Populate vehicles.vehicle_description Using PL/SQL Block */
DECLARE
   CURSOR get_description
   IS
      SELECT DISTINCT vehicle_make || ' ' || vehicle_model AS vehicle_desc
      FROM oltp_vehicles;
BEGIN
   FOR i IN get_description
   LOOP
      INSERT INTO vehicles (vehicle_code, vehicle_description)
         VALUES (vehicle_code_seq.nextval, i.vehicle_desc);
   END LOOP;
END;

/********************* Project 4 Code *********************/

/* 1a. Create 'times' Star Schema Dimension Table */
CREATE TABLE times (
   sale_day DATE        NOT NULL,
   day_type VARCHAR2(7) NOT NULL
);

ALTER TABLE times
    ADD CONSTRAINT pk_sale_day PRIMARY KEY (sale_day);
    
/* 1b. Using PL/SQL Procedure, populate 'times' table */
DECLARE
    CURSOR get_day_type
    IS
        SELECT DISTINCT sale_date FROM sales;
        l_day_type VARCHAR2(7);
    BEGIN
        FOR i IN get_day_type
        LOOP
            CASE
                WHEN i.sale_date = TO_DATE('01-01', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN i.sale_date = TO_DATE('01-15', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN i.sale_date = TO_DATE('02-19', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN i.sale_date = TO_DATE('05-27', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN i.sale_date = TO_DATE('07-04', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN i.sale_date = TO_DATE('09-02', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN i.sale_date = TO_DATE('10-14', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN i.sale_date = TO_DATE('11-11', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN i.sale_date = TO_DATE('11-28', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN i.sale_date = TO_DATE('12-25', 'MM-DD') THEN
                    l_day_type := 'Holiday';
                WHEN TO_CHAR(i.sale_date, 'DY') IN ('SAT', 'SUN') THEN
                    l_day_type := 'Weekend';
                ELSE l_day_type := 'Weekday';
            END CASE;
            INSERT INTO times (sale_day, day_type)
                VALUES (i.sale_date, l_day_type);
        END LOOP;
    END;
    
/* 1c. Execute SELECT statement to show summary of table */
SELECT
    day_type,
    COUNT(*),
    MIN(sale_day),
    MAX(sale_day)
FROM
    times
GROUP BY
    day_type
ORDER BY
    day_type;

/* 2a. Create 'sales_facts' Star Schema Fact Table */
CREATE TABLE sales_facts (
   sale_day         DATE   NOT NULL,
   vehicle_code     NUMBER NOT NULL,
   plan_ID          NUMBER NOT NULL,
   dealer_ID        NUMBER NOT NULL,
   vehicles_sold    NUMBER NOT NULL,
   gross_sales_amt  NUMBER NOT NULL
);

ALTER TABLE sales_facts
   ADD (
      CONSTRAINT pk_all_dimensions PRIMARY KEY (sale_day, vehicle_code, plan_ID, dealer_ID),
      CONSTRAINT fk_dim_sale_day FOREIGN KEY (sale_day)
         REFERENCES times (sale_day)
         ON DELETE CASCADE,
      CONSTRAINT fk_dim_vehicle_code FOREIGN KEY (vehicle_code)
         REFERENCES vehicles (vehicle_code)
         ON DELETE CASCADE,
      CONSTRAINT fk_dim_plan_ID FOREIGN KEY (plan_ID)
         REFERENCES financing_plans (plan_ID)
         ON DELETE CASCADE,
      CONSTRAINT fk_dim_dealer_ID FOREIGN KEY (dealer_ID)
         REFERENCES dealerships (dealer_ID)
         ON DELETE CASCADE
   );
   
/* 2b. DESCRIBE 'sales_facts' after creation */
DESCRIBE sales_facts;

/* 3. SELECT COUNT(*) FOR all dimension tables */
SELECT COUNT(*) FROM financing_plans;

SELECT COUNT(*) FROM dealerships;

SELECT COUNT(*) FROM vehicles;

SELECT COUNT(*) FROM times;

/* 4a. Using PL/SQL stored procedure, populate 'sales_facts' table */
-- unfinished!
CREATE OR REPLACE PROCEDURE populate_sales_facts
IS
    l_sale_day DATE;
    l_vehicle_code NUMBER;
    l_plan_ID NUMBER;
    l_dealer_ID NUMBER;
    l_count NUMBER;
    l_gross_sales NUMBER;
    CURSOR dimensions
    IS
        SELECT
            sale_day,
            --vehicle_code,
            plan_ID,
            dealer_ID,
            COUNT(*),
            SUM(gross_sale_price)
        FROM
            times
        CROSS JOIN
            --vehicles
        CROSS JOIN
            financing_plans
        CROSS JOIN
            dealerships
        CROSS JOIN
            sales;
BEGIN
    OPEN dimensions;
    LOOP
        FETCH dimensions
            INTO l_sale_day, l_vehicle_code, l_plan_ID, l_dealer_ID, l_count, l_gross_sales;
        EXIT WHEN dimensions%NOTFOUND;
        
        IF l_count != 0
        THEN
            INSERT INTO sales_facts(sale_day, vehicle_code, plan_ID, dealer_ID, vehicles_sold, gross_sales_amt)
                VALUES(l_sale_day, l_vehicle_code, l_plan_ID, l_dealer_ID, l_count, l_gross_sales);
        END IF;
    END LOOP;
    CLOSE dimensions;
END;

/* 4b. Execute SELECT COUNT(*) and SELECT SUM(vehicles_sold) FROM sales_facts */
SELECT COUNT(*) FROM sales_facts;

SELECT SUM(vehicles_sold) FROM sales_facts;
