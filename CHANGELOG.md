# Changelog

## 0.0.4
* More Rspec feature specs. All main functionality is now covered with 
integration tests.
* Timestamps page for a job now correctly shows timestamps for jobs which
inherit from `ActiveJob::Base`.
* Timestamps page for a job shows timestamps as links.
* Some layout and styling improvements.

## 0.0.3
* Fixed timestamps page.
* Added Rspec features to cover more functionality that was previously untested.

## 0.0.2
* Add documentation for methods and classes.
* Clean up lots of Rubocop issues with the code style.
* Set up Travis CI.
* Add various badges to the README.
* Add runtime dependencies to prevent a bug with earlier versions of 
resque-scheduler, which defined `Resque::Scheduler` as a class, rather than a 
module.

## 0.0.1
* Code ported over from the main resque-scheduler gem, extracted from the 
Sinatra interface, and put into a rails engine.
* Test suite converted to use Rspec.