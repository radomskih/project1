import gleam/erlang/process.{type Subject, new_subject, receive, send}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/actor
import gleam/otp/static_supervisor
import gleam/otp/supervision.{ChildSpecification, Temporary, Worker}
import gleam/string

pub fn main() {
  let n = 10_000
  let m = 2
  let sp = 100

  let assert Ok(_supervisor_actor) =
    actor.new(Nil)
    //|> actor.on_message(supervisor_handle_message)
    |> actor.start

  let subject: Subject(MessageToSupervisor) = new_subject()

  let builder =
    static_supervisor.new(static_supervisor.OneForOne)
    |> add_workers(n, m, sp, subject)

  let assert Ok(_supervisor) = static_supervisor.start(builder)
  //io.println("supervisor started " <> int.to_string(n) <> " workers.")

  let list = supervisor_loop(subject, [])
  let list_string = list.map(list, int.to_string) |> string.join("\n")
  io.println(list_string)
}

pub type MessageToSupervisor {
  Result(start: Int, is_perfect: Bool)
}

pub type MessageToWorker {
  Start
}

fn worker_handle_message(
  state: WorkerState,
  message: MessageToWorker,
) -> actor.Next(WorkerState, MessageToWorker) {
  case message {
    Start -> {
      do_calculations(
        state.start,
        state.len,
        state.supervisor_data,
        state.start - state.sub_problems,
      )
      actor.stop()
    }
  }
  actor.continue(state)
}

fn supervisor_loop(
  subject: Subject(MessageToSupervisor),
  perfect_squares: List(Int),
) {
  case receive(subject, 100) {
    Ok(Result(start, True)) -> {
      let updated_list = list.append([start], perfect_squares)
      supervisor_loop(subject, updated_list)
    }
    Ok(Result(_start, False)) -> {
      supervisor_loop(subject, perfect_squares)
    }
    Error(_) -> {
      perfect_squares
    }
  }
}

//fn supervisor_handle_message(
//_state: Nil,
//message: MessageToSupervisor,
//) -> actor.Next(Nil, MessageToSupervisor) {
//case message {
//Result(_start, True) -> {
//io.println("Perfect square")
//}
//Result(_start, False) -> {
//io.println("Not a perfect square")
//}
//}
//actor.continue(Nil)
//}

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
    Ok(sq_root) -> {
      //io.println(int.to_string(n) <> " " <> float.to_string(sq_root))
      int.to_float(float.round(sq_root)) == sq_root
    }
    Error(_) -> {
      False
    }
  }
}

pub type WorkerState {
  WorkerState(
    start: Int,
    len: Int,
    sub_problems: Int,
    supervisor_data: Subject(MessageToSupervisor),
  )
}

fn add_workers(
  builder: static_supervisor.Builder,
  n: Int,
  len: Int,
  sub_problems: Int,
  supervisor_data: Subject(MessageToSupervisor),
) -> static_supervisor.Builder {
  case n <= 0 {
    True -> builder
    False -> {
      let initial_state = WorkerState(n, len, sub_problems, supervisor_data)
      //io.println("creating worker with start: " <> int.to_string(n))

      let assert Ok(worker) =
        actor.new(initial_state)
        |> actor.on_message(worker_handle_message)
        |> actor.start
      let subject = worker.data
      send(subject, Start)

      let child_spec =
        ChildSpecification(
          start: fn() { Ok(worker) },
          restart: Temporary,
          significant: False,
          child_type: Worker(5000),
        )

      let builder = static_supervisor.add(builder, child_spec)
      add_workers(builder, n - sub_problems, len, sub_problems, supervisor_data)
    }
  }
}

fn do_calculations(
  start: Int,
  len: Int,
  supervisor: Subject(MessageToSupervisor),
  end: Int,
) {
  case start > end {
    True -> {
      case start > 0 {
        True -> {
          let sum = sum_consecutive_squares(start, len)
          let perfect = is_perfect_square(sum)

          //echo "doing calculations for " <> int.to_string(start)
          send(supervisor, Result(start, perfect))
          do_calculations(start - 1, len, supervisor, end)
        }
        False -> {
          Nil
        }
      }
    }
    False -> {
      Nil
    }
  }
}
