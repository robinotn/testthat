#' Create a test.
#'
#' A test encapsulates a series of expectations about small, self-contained
#' set of functionality.  Each test is contained in a \link{context} and
#' contains multiple expectation generated by \code{\link{equivalence}}.
#'
#' Tests are evaluated in their own environments, and should not affect
#' global state.
#'
#' When run from the command line, tests return \code{NULL} if all
#' expectations are met, otherwise it raises an error.
#'
#' @param desc test name.  Names should be kept as brief as possible, as they
#'   are often used as line prefixes.
#' @param code test code containing expectations
#' @export
#' @examples
#' test_that("trigonometric functions match identities", {
#'   expect_equal(sin(pi / 4), 1 / sqrt(2))
#'   expect_equal(cos(pi / 4), 1 / sqrt(2))
#'   expect_equal(tan(pi / 4), 1)
#' })
#' # Failing test:
#' \dontrun{
#' test_that("trigonometric functions match identities", {
#'   expect_equal(sin(pi / 4), 1)
#' })
#' }
test_that <- function(desc, code) {
  test_code(desc, substitute(code), env = parent.frame())
  invisible()
}



# Executes a test.
#
# @keywords internal
# @param description the test name
# @param code the code to be tested, needs to be an unevaluated expression
#   i.e. wrap it in substitute()
# @param env the parent environment of the environment the test code runs in
test_code <- function(description, code, env) {
  new_test_environment <- new.env(parent = env)
  get_reporter()$start_test(description)
  on.exit(get_reporter()$end_test())

  capture_calls <- function(e) {
    # Capture call stack, removing last two calls from end (added by
    # withCallingHandlers), and first frame + 7 calls from start (added by
    # tryCatch etc)
    e$calls <- utils::head(sys.calls()[-seq_len(frame + 7)], -2)
    signalCondition(e)
  }
  frame <- sys.nframe()

  ok <- TRUE
  tryCatch(
    withCallingHandlers(
      eval(code, new_test_environment),
      error = capture_calls,
      message = function(c) invokeRestart("muffleMessage")
    ),
    error = function(e) {
      ok <- FALSE
      report <- expectation_error(e$message, e$calls)
      get_reporter()$add_result(report)
    }, skip = function(e) {
      report <- expectation_skipped(e$message)
      get_reporter()$add_result(report)
    }
  )

  invisible(ok)
}

#' R package to make testing fun!
#'
#' Try the example below. Have a look at the references and learn more
#' from function documentation such as \code{\link{expect_that}}.
#'
#' @details Software testing is important, but, in part because
#' it is frustrating and boring, many of us avoid it.
#'
#' testthat is a new testing framework for R that is easy learn and use,
#' and integrates with your existing workflow.
#'
#' @section Options:
#' \code{testthat.use_colours}: Should the output be coloured? (Default:
#' \code{TRUE}).
#'
#' \code{testthat.summary.max_reports}: The maximum number of detailed test
#' reports printed for the summary reporter (default: 15).
#'
#' @docType package
#' @name testthat
#' @references Wickham, H (2011). testthat: Get Started with Testing.
#' \strong{The R Journal} \emph{3/1} 5-10.
#' \url{http://journal.r-project.org/archive/2011-1/RJournal_2011-1_Wickham.pdf}
#'
#' \url{https://github.com/hadley/testthat}
#'
#' \url{http://adv-r.had.co.nz/Testing.html}
#'
#' @examples
#' library(testthat)
#' a <- 9
#' expect_that(a, is_less_than(10))
#' expect_less_than(a, 10)
NULL
