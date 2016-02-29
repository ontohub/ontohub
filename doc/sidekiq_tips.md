# Sidekiq Tips

## Add job to queue other than specified in the Worker class
You can add a job to a queue different from the one that is specified in the worker class.
Instead of

```ruby
SomeWorker.perform_async(some, arguments)
```

you can execute

```ruby
Sidekiq::Client.push('queue' => 'some_other_queue',
                     'class' => SomeWorker,
                     'args' => [some, arguments])
```
This method accepts the following keys:
* `queue` - the named queue to use, default `'default'`
* `class` - the worker class to call, required
* `args` - an array of simple arguments to the perform method, must be JSON-serializable
* `retry` - whether to retry this job if it fails, `true` or `false`, default `true`
* `backtrace` - whether to save any error backtrace, default `false`

## Add many jobs to a queue
To add tens of thousands of jobs to a queue, it is recommended to use
```ruby
Sidekiq::Client.push_bulk('queue' => 'some_other_queue',
                          'class' => SomeWorker,
                          'args' => [[some1, arguments1],
                                     [some2, arguments2],
                                     [some3, arguments3],
                                     [some4, arguments4],
                                     ])
```
It takes the same arguments as `push` above, but expects the `'args'` to be an array.
It cuts down on the redis round trip latency.
