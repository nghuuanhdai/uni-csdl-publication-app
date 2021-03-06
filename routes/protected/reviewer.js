const e = require('express');
const express = require('express');
const router = express.Router();

const mysql = require('mysql');

const connection = mysql.createConnection({
    host     : 'localhost',
    user     : 'reviewer',
    password : 'reviewer_password',
    database : 'publication'
});
connection.connect();

// ----------------procedure ------------------------------------------//
router.put('/update_info_reviewer', (req,res) => {
    if(!req.privilege.updateAccount) return res.sendStatus(401)
    const s_id                  = req.user.username
    const collaboration_day     = req.body.collaboration_day
    const work_email            = req.body.work_email
    const fname                 = req.body.work_email
    const address               = req.body.address
    const email                 = req.body.email
    const company               = req.body.company
    const job                   = req.body.job
    const degree                = req.body.degree
    const profession            = req.body.profession


    const query = 'call update_information_reviewer(?,?,?,?,?,?,?,?,?,?)'
    connection.query(
        query,
        [s_id,collaboration_day,work_email,fname,address,email,company,job,degree,profession],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.sendStatus(200)
        }
    )
})


router.put('/reviewer_update_review_summary',(req,res)=> {
    if(!req.privilege.review) return res.sendStatus(401)
    const s_id                  = req.user.username
    const p_id                  = req.body.p_id
    const note_for_author       = req.body.note_for_author
    const note_for_paper        = req.body.note_for_paper

    const query = 'call update_review_paper(?,?,?,?)'
    connection.query(
        query,
        [s_id,p_id,note_for_author,note_for_paper],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.sendStatus(200)
        }
    )
})
///



router.get('/reviewer_get_paper_by_type', (req,res) => {
    if(!req.privilege.getPaper) return res.sendStatus(401)
    const s_id          = req.user.username
    const type_paper    = req.body.type_paper

    const query = 'call get_paper_by_type(?,?)'
    connection.query(
        query,
        [s_id,type_paper],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})


router.get('/get_reviewed_paper_by_type_in_years', (req,res) => {
    if (!req.privilege.getPaper) return res.sendStatus(401)
    const s_id          = req.user.username;
    const type_paper    = req.body.type_paper;
    const years         = req.body.years;

    const query = 'call get_reviewed_paper_by_type_in_years(?,?,?)'
    connection.query(
        query,
        [s_id,type_paper,years],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})


router.get('/reviewer_get_paper_of_author', (req,res) => {
    if(!req.privilege.getPaper) return res.sendStatus(401)
    const s_id      = req.user.username
    const author_id = req.body.author_id

    const query = 'call get_paper_of_author(?,?)'
    connection.query(
        query,
        [s_id,author_id],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})


router.get('/get_paper_of_author_in_years', (req,res) => {
    if (!req.privilege.getPaper) return res.sendStatus(401)
    const s_id      = req.user.username
    const author_id = req.body.author_id
    const years     = req.body.years

    const query = 'call get_paper_of_author_in_years(?,?,?)'
    connection.query(
        query,
        [s_id,author_id,years],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})


router.get('/reviewer_get_author_had_reviewed_most', (req,res) => {
    if(!req.privilege.getPaper) return res.sendStatus(401)
    const s_id = req.user.username

    const query = 'call get_author_had_reviewed_most_by_reviewer(?)'
    connection.query(
        query,
        [s_id],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})



router.get('/get_result_review_in_years' , (req,res) => {
    if(!req.privilege.review) return res.sendStatus(401)
    const s_id = req.user.username
    const years = req.body.years

    const query = 'call get_result_review_in_years(?,?)'
    connection.query(
        query,
        [s_id, years],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})



router.get('/get_top_reviewed_paper_count_years' , (req,res) => {
    if(!req.privilege.review) return res.sendStatus(401)
    const s_id = req.user.username
    const years = req.body.years

    const query = 'call get_top_reviewed_paper_count_years(?,?)'
    connection.query(
        query,
        [s_id, years],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})



router.get('/reviewer_get_best_result_paper' , (req,res) => {
    if(!req.privilege.review) return res.sendStatus(401)
    const s_id = req.user.username

    const query = 'call get_best_result_paper(?)'
    connection.query(
        query,
        [s_id],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})



router.get('/reviewer_get_worst_result_paper' , (req,res) => {
    if(!req.privilege.review) return res.sendStatus(401)
    const s_id = req.user.username

    const query = 'call get_worst_result_paper(?)'
    connection.query(
        query,
        [s_id],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})




router.get('/get_avg_reviewed_paper_count_per_year' , (req,res) => {
    if(!req.privilege.review) return res.sendStatus(401)
    const s_id = req.user.username
    const years = req.body.years

    const query = 'call get_avg_reviewed_paper_count_per_year(?,?)'
    connection.query(
        query,
        [s_id, years],
        (err,results,fields) => {
            if (err) return res.status(500).send(err)
            return res.send(results)
        }
    )
})












module.exports = router;