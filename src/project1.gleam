import gleam/erlang/process.{type Subject, new_subject, receive, send}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/actor
import gleam/otp/static_supervisor
import gleam/otp/supervision.{ChildSpecification, Temporary, Worker}
import gleam/string
import gleam/time/duration
import gleam/time/timestamp

pub fn main() {
  let time_start = timestamp.system_time()

  let n = 1_000_000
  let m = 2
  let sp = 1000
  let num_actors =
    float.round(float.ceiling(int.to_float(n) /. int.to_float(sp)))

  let assert Ok(_supervisor_actor) =
    actor.new(0)
    //|> actor.on_message(supervisor_handle_message)
    |> actor.start

  let subject: Subject(MessageToSupervisor) = new_subject()

  let builder =
    static_supervisor.new(static_supervisor.OneForOne)
    |> static_supervisor.auto_shutdown(static_supervisor.AllSignificant)
    |> add_workers(n, m, sp, subject)

  let assert Ok(_supervisor) = static_supervisor.start(builder)

  supervisor_loop(subject, SupervisorState([], num_actors))

  let time_end = timestamp.system_time()

  let run_time = timestamp.difference(time_start, time_end)
  let t = duration.to_seconds(run_time)
  io.println("total subproblems: " <> int.to_string(n))
  io.print("subproblems per worker: " <> int.to_string(sp) <> "\n")
  io.println("number of workers: " <> int.to_string(num_actors))
  io.println("Overall run time: " <> float.to_string(t))
}

pub type MessageToSupervisor {
  Result(results: List(Int))
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
      let results =
        do_calculations(
          state.start,
          state.len,
          state.start - state.sub_problems,
          [],
        )
      send(state.supervisor_data, Result(results))
      //io.print(
      //"worker " <> int.to_string(state.start) <> " all done! shutting down",
      //)
      actor.stop()
    }
  }
}

fn supervisor_loop(
  subject: Subject(MessageToSupervisor),
  state: SupervisorState,
) {
  case receive(subject, 1000) {
    Ok(Result(results)) -> {
      let updated_list = list.append(results, state.results)
      let updated_num = state.num_left - 1
      let new_state = SupervisorState(updated_list, updated_num)
      case updated_num == 0 {
        True -> {
          let list_string =
            list.map(updated_list, int.to_string) |> string.join("\n")
          io.println(list_string)
          actor.stop()
        }
        False -> {
          supervisor_loop(subject, new_state)
        }
      }
    }
    Error(_) -> {
      supervisor_loop(subject, state)
    }
  }
}

//fn supervisor_handle_message(
//state: SupervisorState,
//message: MessageToSupervisor,
//) -> actor.Next(SupervisorState, MessageToSupervisor) {
//case message {
//Result(results) -> {
//io.println("got results")
//let updated_list = list.append(results, state.results)
//let updated_num = state.num_left - 1
//let new_state = SupervisorState(updated_list, updated_num)
//case updated_num == 0 {
//True -> {
//let list_string =
//list.map(updated_list, int.to_string) |> string.join("\n")
//io.println(list_string)
//actor.stop()
//}
//False -> {
//actor.continue(new_state)
//}
//}
//}
//}
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

pub type SupervisorState {
  SupervisorState(results: List(Int), num_left: Int)
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
          significant: True,
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
  end: Int,
  results: List(Int),
) -> List(Int) {
  case start > end {
    True -> {
      case start > 0 {
        True -> {
          let sum = sum_consecutive_squares(start, len)
          let perfect = is_perfect_square(sum)

          case perfect {
            True -> {
              let updated_results = list.append(results, [start])
              do_calculations(start - 1, len, end, updated_results)
            }
            False -> {
              do_calculations(start - 1, len, end, results)
            }
          }
        }
        False -> {
          results
        }
      }
    }
    False -> {
      results
    }
  }
}
