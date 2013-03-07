raggle
======

**raggle** is a [Shiny](http://www.rstudio.com/shiny) application for data mining competition. It was designed for [Stat503](http://catalog.iastate.edu/showcourse/?code=STAT-503&edition=2012-13) (Exploratory Methods & Data Mining). The name was from [Kaggle](http://www.kaggle.com), and the letter `r` stands for the R language.

## How it works

The participant uploads a CSV file which contains the prediction labels corresponding to the id's of the test cases. For example, a file `Group1Attempt1.csv` like this:

```
"id","genre"
11111111, "rock"
1234567, "jazz"
....
```

This file can be created by `write.csv()`, e.g.

```r
write.csv(data.frame(id = your_id, genre = your_prediction), 'Group1Attempt1.csv',
          row.names = FALSE)
```

Be sure that your id's and predictions match with each other. This app will find your predictions by id's and compare them to the true labels.

## The web interface

The app is deployed at http://thyme.stat.iastate.edu:8100 Choose your group number, fill out the password (sent from the instructor) and upload your prediction file. Then you will see your prediction error rate on the right.

When an R error occurs, you will see the error message in red on the right as well.
