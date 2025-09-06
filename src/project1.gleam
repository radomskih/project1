//import gleam/erlang/process.{type Subject}
import gleam/float
import gleam/int
import gleam/io
import gleam/otp/actor
import gleam/otp/static_supervisor
import gleam/otp/supervision.{ChildSpecification, Permanent, Worker}
import gleam/result

pub fn main() {
  let n = 5
  let builder =
    static_supervisor.new(static_supervisor.OneForOne)
    |> add_workers(n)

  let assert Ok(_supervisor) = static_supervisor.start(builder)

  io.println("supervisor started " <> int.to_string(n) <> " workers.")
}

pub type MessageToWorker {
  Check(Int, Int)
}

pub type MessageToSupervisor {
  Result(Int, Bool)
}

fn worker_handle_message(
  state: Int,
  message: MessageToWorker,
) -> actor.Next(Int, MessageToWorker) {
  case message {
    Check(start, len) -> {
      let sum = sum_consecutive_squares(start, len)
      let state = case is_perfect_square(sum) {
        True -> {
          actor.send(reply_to, Result(start, True))
          1
        }
        False -> {
          actor.send(reply_to, Result(start, False))
          0
        }
      }

      actor.continue(state)
    }
  }
}

fn supervisor_handle_message(
  state: Nil,
  message: MessageToSupervisor,
) -> actor.Next(Nil, MessageToSupervisor) {
  case message {
    Result(start, True) -> {
      io.println("Perfect square")
    }
    Result(sum, False) -> {
      io.println("Not a perfect square")
    }
  }
  actor.continue(Nil)
}

fn sum_squares_up_to(n: Int) -> Int {
  { n * { n + 1 } * { 2 * n + 1 } } / 6
}

fn sum_consecutive_squares(start: Int, len: Int) -> Int {
  let end = start + len - 1
  sum_squares_up_to(end) - sum_squares_up_to(start - 1)
}

fn is_perfect_square(n: Int) -> Bool {
  let sq_root = float.square_root(int.to_float(n))
  case sq_root {
    Ok(root) -> {
      int.to_float(float.round(root)) == root
    }
    Error(_) -> False
  }
}

fn add_workers(
  builder: static_supervisor.Builder,
  n: Int,
) -> static_supervisor.Builder {
  case n <= 0 {
    True -> builder
    False -> {
      let child_spec =
        ChildSpecification(
          start: fn() {
            actor.new(0)
            |> actor.on_message(worker_handle_message)
            |> actor.start
          },
          restart: Permanent,
          significant: False,
          child_type: Worker(5000),
        )
      let builder = static_supervisor.add(builder, child_spec)
      add_workers(builder, n - 1)
    }
  }
}
