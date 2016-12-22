library(ggplot2)
library(tidyr)
library(knitr)
require("RPostgreSQL")

# Settting directory
setwd("~/Documents/github_portfolio/moip/case2")

# Setting constants
img_path <- "viz/"
plot_color <- "darkblue"

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# creates a connection to the postgres database
con <- dbConnect(drv, dbname = "postgres",
                 host = "localhost", port = 5432,
                 user = "your_username_here", password = "your_password_here")

# Loans Time Series
query <- "select cast(date_trunc('month',loan_date) as date) year_month, 
count(*) as cnt, sum(amount) as total_amount from moip.master_table
group by 1;"
df <- dbGetQuery(con, query)

p <- ggplot(df, aes(year_month, total_amount)) 
p <- p + geom_line(colour = plot_color) + geom_point(colour ="black", size = 1)
p <- p + labs(title = "Total Amount Loaned \n", x = "", y = "Dollars")
p <- p + theme_bw()
p

p <- ggplot(df, aes(year_month, cnt)) 
p <- p + geom_line(colour = plot_color) + geom_point(colour ="black", size = 1)
p <- p + labs(title = "Number of Loans \n", x = "", y = "Dollars")
p <- p + theme_bw()
p

ggsave("loan_time_series.png", p, path = img_path)

query <- "select cast(date_trunc('month',loan_date) as date) year_month,status, 
count(*) as cnt, sum(amount) as total_amount from moip.master_table
group by 1,status;"
df <- dbGetQuery(con, query)

p <- ggplot(df, aes(year_month, cnt)) 
p <- p + geom_line(aes(colour = status))
p <- p + labs(title = "Number of Loans \n", x = "", y = "Dollars")
p <- p + theme_bw()
p

ggsave("loan_time_series_status.png", p, path = img_path)

query <- "select status, type,count(*) as cnt,sum(amount) as total_amount from(
select * from moip.master_table as LHS
LEFT JOIN
(select disp_id, type from moip.credit_card) as credit_table
ON LHS.disp_id = credit_table.disp_id) as subq
group by status, type;"
df <- dbGetQuery(con, query)

my_title <-"Loan Status Distribution by Credit Card Holder \n"
p <- ggplot(df, aes(status, cnt)) + theme_bw()
p <- p + geom_bar(fill = "black", stat = "identity") 
p <- p + labs(title = my_title, x = "Loan Status", y = "Count")
p <- p + facet_wrap(~type)
p

ggsave("loan_status_card.png", p, path = img_path)

query <- 'select status, region,count(*) as cnt,sum(amount) as total_amount from(
select * from moip.master_table as LHS
LEFT JOIN
(select "A1" as district_id, "A3" as region from moip.demograph) as demograph_table
ON LHS.district_id = demograph_table.district_id) as subq
group by status, region;'
df <- dbGetQuery(con, query)

my_title <-"Loan Status Distribution by Region \n"
p <- ggplot(df, aes(status, cnt)) + theme_bw()
p <- p + geom_bar(fill = "black", stat = "identity") 
p <- p + labs(title = my_title, x = "Loan Status", y = "Count")
p <- p + facet_wrap(~region)
p

ggsave("loan_status_region.png", p, path = img_path)

query <- 'select payments,status from moip.master_table;'
df <- dbGetQuery(con, query)

my_title <-"Monthly Payment Distribution by Status \n"
p <- ggplot(df, aes(payments)) + theme_bw()
p <- p + geom_density(aes(colour= status))
p <- p + labs(title = my_title)
p <- p + facet_wrap(~status)
p

ggsave("payment_status_density.png", p, path = img_path)

query <- 'select duration,status from moip.master_table;'
df <- dbGetQuery(con, query)

my_title <-"Duration Distribution by Status \n"
p <- ggplot(df, aes(duration)) + theme_bw()
p <- p + geom_density(aes(colour= status))
p <- p + labs(title = my_title)
p <- p + facet_wrap(~status)
p

ggsave("duration_status_density.png", p, path = img_path)
