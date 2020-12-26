DROP DATABASE IF EXISTS PUBLICATION;
CREATE DATABASE PUBLICATION;
USE PUBLICATION;
CREATE TABLE SCIENTIST
(
	ID varchar(45) primary KEY,
    FNAME TEXT,
    ADDRESS TEXT,
    EMAIL TEXT,
    COMPANY TEXT,
    JOB TEXT,
    DEGREE TEXT,
    PROFESSION TEXT
);
CREATE TABLE EDITOR
(
	S_ID varchar(45) primary key,
    APPOINTED_DATE DATE NOT NULL,
    foreign key (S_ID) references SCIENTIST(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE REVIEWER
(
	S_ID varchar(45) primary KEY,
	COLLABORATION_DATE DATE NOT NULL,
    WORK_EMAIL TEXT NOT NULL,
    foreign key (S_ID) references SCIENTIST(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE CONTACT_AUTHOR
(
	S_ID varchar(45) primary KEY,
    foreign key (S_ID) references SCIENTIST(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE AUTHOR
(
	S_ID varchar(45) primary KEY,
    foreign key (S_ID) references SCIENTIST(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE CRITERIA
(
	ID INT auto_increment primary KEY,
    CR_DESCRIPTION TEXT
);
CREATE TABLE PAPER
(
	ID VARCHAR(45) PRIMARY KEY,
    TITLE TEXT NOT NULL,
    SUMMARY TEXT,
    ASSOCIATED_FILE TEXT NOT NULL,
    PAGE_COUNT INT NOT NULL,
    SENT_BY VARCHAR(45) NOT NULL,
    SENT_DATE DATE NOT NULL,
    STATUS ENUM ('UNSOLVED_REVIEW','REVIEW', 'RESPOND_REVIEW', 'COMPLETE_REVIEW', 'PUBLICATION', 'POSTED') NOT NULL,
    foreign key (SENT_BY) references CONTACT_AUTHOR(S_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PAPER_AUTHORS
(
	P_ID VARCHAR(45),
    AUTHOR_ID VARCHAR(45),
    PRIMARY KEY (P_ID, AUTHOR_ID),
	foreign key (P_ID) references PAPER(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key (AUTHOR_ID) references AUTHOR(S_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE RESEARCH_PAPER
(
	P_ID VARCHAR(45) primary KEY,
    foreign key (P_ID) references PAPER(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE RESEARCH_OVERVIEW_PAPER
(
	P_ID VARCHAR(45) primary KEY,
    foreign key (P_ID) references PAPER(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE BOOK
(
	ISBN VARCHAR(45) primary KEY,
    PAGE_COUNT INT,
    PUBLISH_YEAR YEAR,
    TITLE TEXT,
    PUBLISHER TEXT NOT NULL
);
CREATE TABLE BOOK_REVIEW
(
	P_ID VARCHAR(45) primary KEY,
    ISBN VARCHAR(45) NOT NULL,
    foreign key (P_ID) references PAPER(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key (ISBN) references BOOK(ISBN) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE REVIEW_ASSIGMENT_DETAIL
(
	P_ID VARCHAR(45) PRIMARY KEY,
    REVIEWING_DATE DATE NOT NULL,
	NOTE TEXT,
    INFORM_DATE DATE,
    RESULT ENUM('REJECTION', 'MINNOR_REVISION', 'MAJOR_REVISION', 'ACCEPTANCE'),
    foreign key (P_ID) references PAPER(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE REVIEWER_REVIEW_ASSIGNMENT
(
    REVIEWER_ID VARCHAR(45),
    PAPER_ID VARCHAR(45),
    primary key (REVIEWER_ID, PAPER_ID),
   	foreign key (REVIEWER_ID) references REVIEWER(S_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key (PAPER_ID) references REVIEW_ASSIGMENT_DETAIL(P_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE EDITOR_REVIEW_ASSIGNMENT
(
	EDITOR_ID VARCHAR(45),
    PAPER_ID VARCHAR(45),
    primary key (EDITOR_ID, PAPER_ID),
    foreign key (EDITOR_ID) references EDITOR(S_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key (PAPER_ID) references REVIEW_ASSIGMENT_DETAIL(P_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE REVIEW_SUMMARY
(
	P_ID VARCHAR(45),
    REVIEWER_ID VARCHAR(45),
    NOTE_FOR_AUTHOR TEXT,
    NOTE_ABOUT_PAPER TEXT,
	PRIMARY KEY (P_ID, REVIEWER_ID),
    foreign key (P_ID) references REVIEWER_REVIEW_ASSIGNMENT(PAPER_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key (REVIEWER_ID) references REVIEWER_REVIEW_ASSIGNMENT(REVIEWER_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE CRITERIA_REVIEW
(
	P_ID VARCHAR(45),
    REVIEWER_ID VARCHAR(45),
    CRITERIA_ID INT,
    SENT_DATE DATE NOT NULL,
    REVIEW_CONTENT TEXT,
    REVIEW_SCORE INT NOT NULL,
    primary key (P_ID, REVIEWER_ID ,CRITERIA_ID),
	foreign key (P_ID) references REVIEWER_REVIEW_ASSIGNMENT(PAPER_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key (REVIEWER_ID) references REVIEWER_REVIEW_ASSIGNMENT(REVIEWER_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key (CRITERIA_ID) references CRITERIA(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE PAPER_KEY_WORD
(
	P_ID VARCHAR(45),
	KEYWORD VARCHAR(45),
    primary key (P_ID, KEYWORD),
    foreign key (P_ID) references PAPER(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE SCIENTIST_PHONE_NUMBER
(
	S_ID VARCHAR(45),
    PHONE_NUM VARCHAR(45),
    PRIMARY KEY (S_ID, PHONE_NUM),
    foreign key (S_ID) references SCIENTIST(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE BOOK_AUTHOR
(
    ISBN varchar(45),
    AUTHOR_NAME VARCHAR(45),
    primary key (ISBN, AUTHOR_NAME),
    foreign key (ISBN) references BOOK(ISBN) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE PUBLICATION_DETAIL
(
	P_ID varchar(45),
    DOI date not null,
    OPEN_ACCESS BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (P_ID) references PAPER(ID) ON DELETE CASCADE ON UPDATE CASCADE
)