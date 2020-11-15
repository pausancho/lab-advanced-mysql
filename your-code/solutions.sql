/* 
Challenge 1 - Most Profiting Authors

In this challenge you'll find out who are the top 3 most profiting authors in the publications database? Step-by-step guidances 
to train your problem-solving thinking will help you get through this lab.

In order to solve this problem, it is important for you to keep the following points in mind:

In table sales, a title can appear several times. The royalties need to be calculated for each sale.

Despite a title can have multiple sales records, the advance must be calculated only once for each title.

In your eventual solution, you need to sum up the following profits for each individual author:

All advances, which are calculated exactly once for each title.

All royalties in each sale.

Therefore, you will not be able to achieve the goal with a single SELECT query, you will need to use subqueries. 

Instead, you will need to follow several steps in order to achieve the solution. There is an overview of the steps below:

*/

USE publications;

-- 1. Calculate the royalty of each sale for each author and the advance for each author and publication.

-- 2. Using the output from Step 1 as a subquery, aggregate the total royalties for each title and author.

-- 3. Using the output from Step 2 as a subquery, calculate the total profits of each author by aggregating the advances 
-- and total royalties of each title.


/* 
Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication

Write a SELECT query to obtain the following output:

Title ID 
Author ID
Advance of each title and author

The formula is: advance = titles.advance * titleauthor.royaltyper / 100

Royalty of each sale

The formula is: sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100

Note that titles.royalty and titleauthor.royaltyper are divided by 100 respectively because they are percentage numbers instead of floats.
In the output of this step, each title may appear more than once for each author. This is because a title can have more than one sale.
*/

SELECT * FROM titles LIMIT 10;
SELECT * FROM titleauthor LIMIT 10;
SELECT * FROM sales LIMIT 10;

SELECT titles.title_id, titleauthor.au_id, ROUND(titles.advance * titleauthor.royaltyper / 100) AS Advance
FROM titles
INNER JOIN titleauthor ON titles.title_id = titleauthor.title_id;

SELECT titles.title_id, titleauthor.au_id, 
ROUND(titles.advance * titleauthor.royaltyper / 100) AS Advance,
ROUND(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) AS Royalties
FROM titles
INNER JOIN titleauthor ON titles.title_id = titleauthor.title_id
INNER JOIN sales ON sales.title_id = titles.title_id
ORDER BY Royalties DESC;

/*
Step 2: Aggregate the total royalties for each title and author

Using the output from Step 1, write a query, containing a subquery, to obtain the following output:

Title ID
Author ID
Aggregated royalties of each title for each author

Hint: use the SUM subquery and group by both au_id and title_id

In the output of this step, each title should appear only once for each author.

*/

SELECT title_id, au_id , SUM(Royalties) AS Royalties, SUM(Advance) AS Advance  FROM 
	(SELECT titles.title_id, titleauthor.au_id, 
	ROUND(titles.advance * titleauthor.royaltyper / 100) AS Advance,
	ROUND(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) AS Royalties
	FROM titles
	INNER JOIN titleauthor ON titles.title_id = titleauthor.title_id
	INNER JOIN sales ON sales.title_id = titles.title_id) sub
    GROUP BY 1, 2
    ORDER BY 3 DESC;


/*
Step 3: Calculate the total profits of each author
Now that each title has exactly one row for each author where the advance and royalties are available, 
we are ready to obtain the eventual output. 
Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:

Author ID

Profits of each author by aggregating the advance and total royalties of each title
Sort the output based on a total profits from high to low, and limit the number of rows to 3

*/

SELECT au_id, (Royalties + Advance) AS Total_Profit
FROM
	(SELECT title_id, au_id , SUM(Royalties) AS Royalties, SUM(Advance) AS Advance 
FROM 
	(SELECT titles.title_id, titleauthor.au_id, 
	ROUND(titles.advance * titleauthor.royaltyper / 100) AS Advance,
	ROUND(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) AS Royalties
	FROM titles
	INNER JOIN titleauthor ON titles.title_id = titleauthor.title_id
	INNER JOIN sales ON sales.title_id = titles.title_id) sub
    GROUP BY 1, 2
    ORDER BY 3 DESC) sub2
    ORDER BY 2 DESC;
    
 
/*
Challenge 2 - Alternative Solution

In the previous challenge, you have developed your solution the following way:

Derived tables (subqueries).(see reference)
We'd like you to try the other way:

Creating MySQL temporary tables and query the temporary tables in the subsequent steps.
*/

-- Table 1

DROP TEMPORARY TABLE first_one;
CREATE TEMPORARY TABLE first_one
SELECT titles.title_id, titleauthor.au_id, 
ROUND(titles.advance * titleauthor.royaltyper / 100) AS Advance,
ROUND(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) AS Royalties
FROM titles
INNER JOIN titleauthor ON titles.title_id = titleauthor.title_id
INNER JOIN sales ON sales.title_id = titles.title_id
ORDER BY Royalties DESC;

-- Table 2

DROP TEMPORARY TABLE second_one;
CREATE TEMPORARY TABLE second_one
SELECT title_id, au_id , SUM(Royalties) AS Royalties, SUM(Advance) AS Advance
FROM first_one
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Table 3


SELECT au_id, (Royalties + Advance) AS Total_Profit
FROM second_one
ORDER BY 2 DESC;


/*
Challenge 3

Elevating from your solution in Challenge 1 & 2, create a permanent table named most_profiting_authors to hold the data about 
the most profiting authors. The table should have 2 columns:

au_id - Author ID
profits - The profits of the author aggregating the advances and royalties
*/

CREATE TABLE most_profiting_authors 
SELECT au_id, SUM(Royalties + Advance) AS Total_Profit
FROM second_one 
GROUP BY au_id
ORDER BY Total_Profit DESC
LIMIT 3;


SELECT * FROM most_profiting_authors