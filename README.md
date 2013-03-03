raggle
======

**raggle** is a [Shiny](http://www.rstudio.com/shiny) application for data mining competition. It was designed for [Stat503](http://catalog.iastate.edu/showcourse/?code=STAT-503&edition=2012-13) (Exploratory Methods & Data Mining). The name was from [Kaggle](http://www.kaggle.com), and the letter `r` stands for the R language.

## How it works

The participant simply uploads a text file which contains the prediction labels corresponding to the test set (please be very careful about the order of the labels; the i-th label in your prediction file must correspond to the i-th row in the test set).

As one simple example, suppose you were given the training set [`TrainData`](https://dl.dropbox.com/u/15335397/misc/TrainData) which is a CSV file, and you built a classification tree on it:

```r
# the training set
df = read.csv('http://dl.dropbox.com/u/15335397/misc/TrainData')
str(df)
library(rpart)
fit = rpart(Species ~ ., data = df)

# the test set
testData = read.csv('http://dl.dropbox.com/u/15335397/misc/TestData')

# prediction
pred_labels = predict(fit, newdata = testData, type = 'class')
```

Once we have got the predictions, we can write them into a text file and upload it to the server.

```r
writeLines(pred_labels, 'Group1Attempt1.txt')
```

I wrote my labels in a text file named `Group1Attempt1.txt`, and this is the (only) file to upload. Besure to check if your predictions are character labels -- some R functions/packages may give you a matrix of probabilities instead.

## The web interface

The app is deployed at http://thyme.stat.iastate.edu:8100 Choose your group number, fill out the password (sent from the instructor) and upload your prediction file. Then you will see your error rate on the right. When an error occurs, you will see the error message on the right as well.
