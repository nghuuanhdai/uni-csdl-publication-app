use publication;

-- 1 update reviewer info
drop procedure if exists update_information_reviewer ;
delimiter $$
create procedure update_information_reviewer
(
	reviewer_id varchar(45) , collaboration_day date, work_email varchar(45), fname text, address text, email text, company text , job text, degree text, profession text
)
begin

	update reviewer r
    set r.collaboration_date = collaboration_day ,
		r.work_email = work_email
	where r.s_id = reviewer_id;
    
  update scientist s
  set s.fname = fname,
  s.address = address,
      s.email = email,
      s.company = company,
      s.job = job,
      s.degree = degree,
      s.profession = profession
  where s.id = reviewer_id;

end$$
delimiter ;


grant execute on procedure publication.update_information_reviewer to reviewer@localhost;

-- 2 update reviews
grant select, insert, update, delete on review_summary to reviewer@localhost;
grant select, insert, update, delete on criteria_review to reviewer@localhost;

-- 3 get paper by type
drop procedure if exists get_paper_by_type;
delimiter $$
create procedure get_paper_by_type
(
    reviewer_id  varchar(45),
    p_type enum('Research','OverviewPaper','BookReview')
)
begin
   	create temporary table reviewer_papers
	select id 
    from paper 
	join review_assignment_detail on id = review_assignment_detail.p_id
	join reviewer_review_assignment on id = reviewer_review_assignment.paper_id
	where reviewer_review_assignment.reviewer_id = reviewerId;

    if(p_type = 'Research') then
    select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date
    from overview_papers as p
    inner join reviewer_papers on reviewer_papers.id = overview_papers.id;
    end if;

    if(p_type = 'OverviewPaper') then
    select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date
    from research_papers as p
	inner join reviewer_papers on reviewer_papers.id = overview_papers.id;
    end if;

    if(p_type = 'BookReview') then
    select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date
    from book_review_papers as p
	inner join reviewer_papers on reviewer_papers.id = overview_papers.id;
    end if;
end$$

grant execute on procedure publication.get_paper_by_type to reviewer@localhost;

-- 4 get paper reviewed by this viewer in 3 year
drop procedure if exists get_reviewed_paper_by_type_in_years;
delimiter $$
create procedure get_reviewed_paper_by_type_in_years
(
    reviewer_id  varchar(45),
    p_type enum('Research','OverviewPaper','BookReview'),
    year_count int
)
begin
   	create temporary table reviewer_papers
	select id 
    from paper 
	join review_assignment_detail on id = review_assignment_detail.p_id
	join reviewer_review_assignment on id = reviewer_review_assignment.paper_id
	where reviewer_review_assignment.reviewer_id = reviewerId and TIMESTAMPDIFF(YEAR, review_assignment_detail.reviewing_date,CURDATE()) <= year_count;

    if(p_type = 'Research') then
    select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date
    from overview_papers as p
    inner join reviewer_papers on reviewer_papers.id = overview_papers.id;
    end if;

    if(p_type = 'OverviewPaper') then
    select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date
    from research_papers as p
	inner join reviewer_papers on reviewer_papers.id = overview_papers.id;
    end if;

    if(p_type = 'BookReview') then
    select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date
    from book_review_papers as p
	inner join reviewer_papers on reviewer_papers.id = overview_papers.id;
    end if;
end$$

grant execute on procedure publication.get_reviewed_paper_by_type_in_years to reviewer@localhost;

-- 5 get paper of authors
drop procedure if exists get_paper_of_author ;
delimiter $$
create procedure get_paper_of_author
(
	reviewer_id varchar(45),
    author_id varchar(45) 
)
begin

	select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date
    from paper p
    where p.id in (
                    select p_id from review_assignment_detail
                    where p_id in (
                        select r.paper_id
                        from review_review_assignment r
                        where r.reviewer_id = reviewer_id
                    )
                    and result is null
            )
            and p.sent_by = author_id;

end$$
delimiter ;

grant execute on procedure publication.get_paper_of_author to reviewer@localhost;
-- call get_paper_of_author('nnhhaadd_sci','vutrongphung');

-- 6 get paper of authors in 3 years
drop procedure if exists get_paper_of_author_in_years ;
delimiter $$
create procedure get_paper_of_author_in_years
(
	reviewer_id varchar(45), 
    author_id varchar(45),
    year_count int
)
begin
    
    select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date
    from paper p
    where p.id in (
					select p_id from review_assignment_detail
                    where p_id in (
						select r.paper_id
                        from review_review_assignment r
                        where r.reviewer_id = reviewer_id
                    )
                    and result is not null
                    and TIMESTAMPDIFF(YEAR,reviewing_date,CURDATE()) <= year_count
				)
				and p.sent_by = author_id;
end$$
delimiter ;

grant execute on procedure publication.get_paper_of_author_in_years to reviewer@localhost;
-- call get_paper_of_author_in_3_year('nnhhaadd_sci','vutrongphung');

-- 7 get author has been reviewed the most
drop procedure if exists get_author_had_reviewed_most_by_reviewer ;
delimiter $$
create procedure get_author_had_reviewed_most_by_reviewer 
(
	reviewer_id varchar(45)
)
begin
    select sent_by as author, count(sent_by) as num
    from paper
    where id in (	select r.paper_id 
                    from review_review_assignment r
                    where r.reviewer_id = reviewer_id)
    group by sent_by
    order by num desc limit 1;
end$$
delimiter ;

grant execute on procedure publication.get_author_had_reviewed_most_by_reviewer to reviewer@localhost;
-- call get_author_had_reviewed_most_by_reviewer('nnhhaadd_sci');

-- 8 get review result in x years
drop procedure if exists get_result_review_in_years ;
delimiter $$
create procedure get_result_review_in_1_year
(
	reviewer_id varchar(45),
    year_count int
)
begin
    
    select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date, result
    from review_assignment_detail join paper p on p_id = p.id
    where p_id in (
		select r.paper_id
        from review_review_assignment r
        where r.reviewer_id = reviewer_id
    )
    and result is not null
    and TIMESTAMPDIFF(YEAR,reviewing_date,CURDATE()) <= year_count;
    
end$$
delimiter ;

grant execute on procedure publication.get_result_review_in_1_year to reviewer@localhost;
-- call get_result_review_in_1_year('nnhhaadd_sci');

-- 9 get 3 years with the most reviewed paper count
drop procedure if exists get_top_reviewed_paper_count_years;
delimiter $$
create procedure get_top_reviewed_paper_count_years
(
	reviewer_id varchar(45),
    year_count_limit int
)
begin    
	select year(reviewing_date) as year
    from review_assignment_detail
    where p_id in (
		select r.paper_id
        from review_review_assignment r
        where r.reviewer_id = reviewer_id
    )
    group by year(reviewing_date)
    order by count(year(reviewing_date)) desc
    limit year_count_limit;

end$$
delimiter ;

grant execute on procedure publication.get_top_reviewed_paper_count_years to reviewer@localhost;
-- call get_3_year_on_top_review('nnhhaadd_sci');

-- 10 papers with best results
drop procedure if exists get_best_result_paper ;
delimiter $$
create procedure get_best_result_paper
(
	reviewer_id varchar(45)
)
begin
	select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date, result
    from review_assignment_detail join paper p on p_id = p.id
    where p_id in (
		select paper_id
        from review_review_assignment r
        where r.reviewer_id = reviewer_id
    ) and result = 'ACCEPTANCE'
    limit 3;

end$$
delimiter ;

grant execute on procedure publication.get_best_result_paper to reviewer@localhost;

-- call get_best_result_paper('nnhhaadd_sci')

-- 11 papers with worst result
drop procedure if exists get_worst_result_paper ;
delimiter $$
create procedure get_worst_result_paper
(
	reviewer_id varchar(45)
)
begin
	select p.id, p.title, p.summary, p.associated_file, p.page_count, p.sent_by, p.sent_date, result
    from review_assignment_detail join paper p on p_id = p.id
    where p_id in (
		select paper_id
        from review_review_assignment r
        where r.reviewer_id = reviewer_id
    ) and result = 'REJECTION'
    limit 3;

end$$
delimiter ;

grant execute on procedure publication.get_worst_result_paper to reviewer@localhost;

-- call get_worst_result_paper('nnhhaadd_sci')

-- 12 get avg papers 


drop procedure if exists get_avg_reviewed_paper_count_per_year ;
delimiter $$
create procedure get_avg_reviewed_paper_count_per_year
(
	reviewer_id varchar(45),
    number_of_years int
)
begin
    declare total_paper_had_reviewed int;
    select count(p_id)
    into total_paper_had_reviewed
    from review_assignment_detail
    where p_id in (
		select r.paper_id
        from review_review_assignment r
        where r.reviewer_id = reviewer_id
    );
    
	select year(reviewing_date) as year , count(year(reviewing_date)) / total_paper_had_reviewed as avg_paper_of_year_per_5_year
    from review_assignment_detail
    where p_id in (
		select r.paper_id
        from review_review_assignment r
        where r.reviewer_id = reviewer_id
    )
    group by year(reviewing_date)
    order by year(reviewing_date) desc
    limit number_of_years;
end$$
delimiter ;

grant execute on procedure publication.get_avg_reviewed_paper_count_per_year to reviewer@localhost;
-- call get_avg_reviewed_paper_count_per_year('nnhhaadd_sci');