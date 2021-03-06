-- author
use publication;

drop procedure if exists submit_overview_paper;
drop procedure if exists submit_research_paper;
drop procedure if exists submit_book_review;

drop procedure if exists add_author;
delimiter $$
create procedure add_author
(
	p_id varchar(45), author_id varchar(45)
)
begin
	insert paper_authors
    values (p_id, author_id);
end$$
delimiter ;

grant execute on procedure add_author to author@localhost; 

delimiter $$
create procedure submit_overview_paper
(p_id varchar(45), title text, summary text, associated_file text, page_count int, sent_by varchar(45))
begin
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- rollback any error in the transaction
        RESIGNAL;
    END;

    start transaction;
	insert into paper (id, title, summary, associated_file, page_count, sent_by, sent_date)
        values (p_id, title, summary, associated_file, page_count, sent_by, current_date());    
    insert into research_overview_paper
        values (p_id);
    commit;
end$$

create procedure submit_research_paper
(p_id varchar(45), title text, summary text, associated_file text, page_count int, sent_by varchar(45))
begin
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- rollback any error in the transaction
        RESIGNAL;
    END;

    start transaction;
	insert into paper (id, title, summary, associated_file, page_count, sent_by, sent_date)
        values (p_id, title, summary, associated_file, page_count, sent_by, current_date());
    insert into research_paper
        values (p_id);
    commit;
end$$

drop procedure if exists submit_book_review;
delimiter $$
create procedure submit_book_review
(
	p_id varchar(45), title text, summary text, associated_file text, page_count int, sent_by varchar(45), ISBN varchar(45)
)
begin
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- rollback any error in the transaction
        RESIGNAL;
    END;
    
    start transaction;
	insert into paper (id, title, summary, associated_file, page_count, sent_by, sent_date)
        values (p_id, title, summary, associated_file, page_count, sent_by, current_date());
        
    insert into book_review
        values (p_id, ISBN);
    commit;
end$$
delimiter ;

grant execute on procedure publication.submit_overview_paper to author@localhost;
grant execute on procedure publication.submit_research_paper to author@localhost;
grant execute on procedure publication.submit_book_review to author@localhost;

-- 1 update personal information

drop procedure if exists update_information_contact_author ;
delimiter $$
create procedure update_information_contact_author
(
	s_id varchar(45), fname text, address text, email text, company text , job text, degree text, profession text
)
begin
    
  update scientist s
  set s.fname = fname,
	    s.address = address,
      s.email = email,
      s.company = company,
      s.job = job,
      s.degree = degree,
      s.profession = profession
  where s.id = s_id;

end$$
delimiter ;

grant execute on procedure publication.update_information_contact_author to contact_author@localhost;

-- 2 paper update
drop procedure if exists edit_paper;
drop procedure if exists delete_paper;

delimiter $$
create procedure edit_paper
(
	s_id varchar(45), p_id varchar(45), title text, summary text, associated_file text, page_count int, sent_by varchar(45), sent_date date
)
begin
	update paper p
    set p.title = title, 
		p.summary = summary, 
        p.associated_file = associated_file, 
        p.page_count = page_count, 
        p.sent_by = sent_by,
        p.sent_date = sent_date
    where id = p_id and p.sent_by = s_id;
    
	select *
    from paper
    where id = p_id and sent_by = s_id;
end$$

create procedure delete_paper
(
	s_id varchar(45), p_id varchar(45)
)
begin
	select *
    from paper
    where sent_by = s_id and id = p_id;
    
	delete from paper
    where sent_by = s_id and id = p_id;
end$$
delimiter ;

grant execute on procedure edit_paper to author@localhost;
grant execute on procedure edit_paper to contact_author@localhost;
grant execute on procedure delete_paper to contact_author@localhost;

-- 3 get paper authors
drop procedure if exists get_information_book_authors;

delimiter $$
create procedure get_information_book_authors
(
	s_id varchar(45), p_id varchar(45)
)
begin
	select
		id ,
        fname, 
        address, 
        email, 
        company,
        job,
        degree,
        profession
	from scientist
	where id in (
			select author_id
			from paper_authors pa
            join paper p on (pa.p_id = p.id)
			where pa.p_id = p_id and p.sent_by = s_id
	);
end$$
delimiter ;

grant execute on procedure get_information_book_authors to contact_author@localhost;

-- 4 get paper status
drop procedure if exists get_status_paper;

delimiter $$
create procedure get_status_paper
(
	s_id varchar(45), p_id varchar(45)
)
begin
	select status
    from paper
    where id = p_id and sent_by = s_id;
end$$
delimiter ;

grant execute on procedure get_status_paper to author@localhost;

-- 5 get review result
drop procedure if exists get_review_summary;

delimiter $$
create procedure get_review_summary
(
	p_id varchar(45)
)
begin
	select *
    from review_summary rs
    where rs.p_id = p_id;
end$$
delimiter ;

grant execute on procedure get_review_summary to author@localhost;

-- 6 get papers submitted in 1 year
drop procedure if exists get_list_paper_in_for_years;

delimiter $$
create procedure get_list_paper_in_for_years
(
	s_id varchar(45),
	year_count int
)
begin
	select *
    from paper p
    where p.sent_by = s_id 
		and p.sent_date >= DATE_SUB(NOW(),INTERVAL year_count YEAR);
end$$
delimiter ;

grant execute on procedure get_list_paper_in_for_years to author@localhost;

-- 7 get posted paper in 1 year
drop procedure if exists get_list_paper_with_status_for_years;

delimiter $$
create procedure get_list_paper_with_status_for_years
(
	s_id varchar(45),
	year_count int,
	filter_status ENUM('UNSOLVED_REVIEW','REVIEW','RESPOND_REVIEW','COMPLETE_REVIEW','PUBLICATION','POSTED')
)
begin
	select *
    from paper p
    where p.sent_by = s_id 
		and p.status = filter_status
		and p.sent_date >= DATE_SUB(NOW(),INTERVAL year_count YEAR); -- 1 year ago
end$$
delimiter ;

grant execute on procedure get_list_paper_with_status_for_years to author@localhost;

-- 8 get published paper in 1 year
-- call get_list_paper_with_status_for_years("longauthor", 1, 'PUBLICATION');

-- 9 get worst result paper
drop procedure if exists get_papers_with_result;

delimiter $$
create procedure get_papers_with_result
(
	s_id varchar(45),
	result enum('REJECTION', 'MINNOR_REVISION', 'MAJOR_REVISION', 'ACCEPTANCE')
)
begin
	select id, title, summary, associated_file, page_count, sent_by, sent_date, status, result
    from paper p
    join review_assignment_detail rad on (p.id = rad.p_id)
    where p.sent_by = s_id
		and rad.result = result;
end$$
delimiter ;

grant execute on procedure get_papers_with_result to author@localhost;

-- call get_papers_with_result("longauthor", 'REJECT');

-- 10 get total papers in 5 years

drop procedure if exists get_total_papers_in_years;

delimiter $$
create procedure get_total_papers_in_years
(
	s_id varchar(45),
    year_count int
)
begin
	select year(sent_date) as sent_year, count(*) as total_paper
    from paper
    where sent_by = s_id and sent_date >= DATE_SUB(NOW(),INTERVAL year_count YEAR)
    group by year(sent_date)
    order by year(sent_date) desc;
end$$
delimiter ;

grant execute on procedure get_total_papers_in_years to author@localhost;

-- call get_total_papers_in_years("longauthor", 5);

-- 11 get total of research paper in 5 years

drop procedure if exists get_total_papers_of_type_in_years;
delimiter $$
create procedure get_total_papers_of_type_in_years
(
	s_id varchar(45),
    p_type enum('Research','OverviewPaper','BookReview'),
    year_count int
)
begin
	create temporary table author_papers
	select id
    from paper p
    where p.sent_by = s_id
		and p.sent_date >= DATE_SUB(NOW(),INTERVAL year_count YEAR);

    if(p_type = 'Research') then
    select count(*)
    from overview_papers
    inner join author_papers on author_papers.id = overview_papers.id;
    end if;

    if(p_type = 'OverviewPaper') then
    select count(*)
    from research_papers
	inner join author_papers on author_papers.id = overview_papers.id;
    end if;

    if(p_type = 'BookReview') then
    select count(*)
    from book_review_papers
	inner join author_papers on author_papers.id = overview_papers.id;
    end if;
end$$
delimiter ;

grant execute on procedure get_total_papers_of_type_in_years to author@localhost;
-- call get_total_papers_of_type_in_years("longauthor", 'Research', 5);

-- 12 get total overview paper in 5 years
-- call get_total_papers_of_type_in_years("longauthor", 'OverviewPaper', 5);

