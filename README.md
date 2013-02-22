raggle
======

**raggle** is a [Shiny](http://www.rstudio.com/shiny) application for data mining competition. It was designed for [Stat503](http://catalog.iastate.edu/showcourse/?code=STAT-503&edition=2012-13) (Exploratory Methods & Data Mining). The name was from [Kaggle](http://www.kaggle.com), and the letter `r` stands for the R language.

## How it works

The participant uploads an R workspace image (`*.Rdata`) which must contain at least a function named `predict_fun`; this function takes the test set as the the one and only parameter, and gives predictions. Optionally this image can also include a character vector (named `required_pkgs`) of the package names which are used in your model; when you upload the image to the server, all these packages will be loaded/installed automatically.

As one simple example, suppose you were given the training set [`TrainData`](https://dl.dropbox.com/u/15335397/misc/TrainData) which is a CSV file, and you built a classification tree on it:

```r
# the training set
df = read.csv('http://dl.dropbox.com/u/15335397/misc/TrainData')
str(df)
library(rpart)
fit = rpart(Species ~ ., data = df)
# the prediction function
predict_fun = function(testset) {
  as.character(predict(fit, newdata = testset, type = 'class'))
}
```

You defined a function named `predict_fun` which has one argument `testset`, meaning the test dataset. I give you a test set and you return me your predictions as a _character vector_ of the labels.

```r
test = read.csv('http://dl.dropbox.com/u/15335397/misc/TestData')
predict_fun(test)
```

The rest of the job is to save the necessary objects in an `.RData` image, and upload it to the server.

```r
required_pkgs = c('rpart')
ls()  # all objects
# you can use any filenames, e.g. group1attempt3.RData
save(list = c('required_pkgs', 'predict_fun', 'fit'), file = 'mymodel.RData')
```

I created the variable `required_pkgs` so that the server will install the required packages to run my model. The other two objects saved in the file `mymodel.RData` are `predict_fun` and `fit`, because we need them for predictions. In our workspace we actually have the data object `df`, but it is not required by the predictive model, so we do not have to save it along with other objects (although it does not hurt if you also save it).

## The web interface

Choose your group number, fill out the password (sent from the instructor) and upload your `.RData` file. Then you will see your error rate on the right if your model runs without errors.

## Note

Before you upload the `.RData` file, you are recommended to verify if it reall works in a _clean_ R environment.

```r
rm(list = ls(all.names = TRUE))  # remove everything before moving on
load('mymodel.RData')
if (exists('required_pkgs')) {
  sapply(required_pkgs, library, character.only = TRUE)
}
# run the model on the training set
df = read.csv('http://dl.dropbox.com/u/15335397/misc/TrainData')
predict_fun(df)
```

If the prediction function works on the training set, it is likely to work on the test set as well.

The server uses the latest versions of R as well as add-on packages, so make sure your are also using the latest versions of everything.
