library(shiny)

config = './config/' # path to configuration files
testLabels = readLines(file.path(config, 'TestLabels'))
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
    if (file.exists('00LOCK'))
      stop('Another group is submitting their predictions.',
           'Please wait a second, refresh this page and retry.')
    group = as.integer(input$group)
    if (group == 0) return(print_leader())
    if (password[group] != input$pass) return(cat('Please input your password'))
    file.create('00LOCK')  # lock the system temporarily
    on.exit(file.remove('00LOCK'))
    leader = as.matrix(read.csv(leaderFile))
    g = leader[group, ]
    na = which(is.na(g))
    if (length(na) == 0L) {
      cat('Sorry but you have used all the attempts. Take a rest now.\n\n')
      return(print_leader())
    }
    if (is.null(input$rdata)) return(cat('Please upload your prediction file'))
    # save a copy of the upload
    file.copy(input$rdata$datapath,
              file.path(config, sprintf('Group%dAttempt%d.txt', group, ncol(leader) - length(na) + 1)))
    pred = factor(readLines(input$rdata$datapath), levels = unique(testLabels))
    if (any(is.na(pred)))
      stop('your predictions must only contain these labels: ',
      paste(unique(testLabels), collapse = ', '))
    res = table(testLabels, pred, dnn = c('Prediction', 'True Labels'))
    cat('Confusion Matrix\n\n')
    print(res)
    cat('\nPrediction Errors by Class\n\n')
    res = as.matrix(res)
    err = 1 - diag(res) / c(table(testLabels))
    print(err)
    err = mean(err)
    cat('\nAverage Prediction Error: ', err, '\n\n')
    leader = as.matrix(read.csv(leaderFile))
    leader[group, na[1]] = err
    write.csv(leader, leaderFile, row.names = FALSE)
    print_leader()
  })

})
