library(shiny)

config = './config/' # path to configuration files
testLabels = readLines(file.path(config, 'TestLabels'))
testData = read.csv(file.path(config, 'TestData'))
password = readLines(file.path(config, 'password'))
leaderFile = file.path(config, 'leader')

print_leader = function() {
  cat('Leader Board (ordered by the last attempt):\n\n')
  leader = read.csv(leaderFile)
  idx = order(apply(leader, 1, function(x) {
    if (all(is.na(x))) return(1)
    tail(x[!is.na(x)], 1)
  }))
  print(leader[idx, ], digits = 4)
}
shinyServer(function(input, output) {

  output$howdy = reactiveText(function() {
    if (input$group == '0') return()
    attempts = sum(is.na(as.matrix(read.csv(leaderFile))[as.integer(input$group), ]))
    sprintf('Howdy, Group %s (%s attempts left)', input$group, attempts)
  })

  output$results = reactivePrint(function() {
    group = as.integer(input$group)
    if (group == 0) return(print_leader())
    if (password[group] != input$pass) return(cat('Please input your password'))
    leader = as.matrix(read.csv(leaderFile))
    g = leader[group, ]
    na = which(is.na(g))
    if (length(na) == 0L) {
      cat('Sorry but you have used all the attempts. Take a rest now.\n\n')
      return(print_leader())
    }
    if (is.null(input$rdata)) return(cat('Please upload your .RData file'))
    if (!grepl('\\.RData$', input$rdata$name, ignore.case = TRUE))
      stop('The file extension must be .RData!')
    # make sure the global environment is clean
    rm(list = ls(globalenv(), all.names = TRUE), envir = globalenv())
    load(input$rdata$datapath, envir = globalenv())
    if (!exists('predict_fun', envir = globalenv(), mode = 'function'))
      stop('There is no function called predict_fun() in your workspace!')
    if (exists('required_pkgs', envir = globalenv(), mode = 'character')) {
      pkgs = get('required_pkgs', envir = globalenv(), mode = 'character')
      for (i in setdiff(pkgs, .packages(TRUE))) install.packages(i)
      sapply(pkgs, library, character.only = TRUE)
    }
    # save a copy of the R data image
    file.copy(input$rdata$datapath,
              file.path(config, sprintf('Group%dAttempt%d.RData', group, ncol(leader) - length(na) + 1)))
    pred = factor(predict_fun(testData), levels = unique(testLabels))
    res = table(testLabels, pred, dnn = c('Prediction', 'True Labels'))
    cat('Confusion Matrix\n\n')
    print(res)
    cat('\nPrediction Errors by Class\n\n')
    res = as.matrix(res)
    print(1 - diag(res) / c(table(testLabels)))
    err = 1 - sum(diag(res)) / length(testLabels)
    leader[group, na[1]] = err
    write.csv(leader, leaderFile, row.names = FALSE)
    cat('\nOverall Error Rate: ', err, '\n\n')
    print_leader()
    cat('\nSession Info:\n\n')
    print(sessionInfo())
  })

})
