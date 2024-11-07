# Isolates
## How dart runs:
1. Flutter apps do all of their work on a single isolate – the main isolate.
2. All Dart code runs in isolates, which are similar to threads, but differ in that isolates have their own isolated memory.
3. Isolates do not share state in any way, and can only communicate by messaging.
4. In most cases, this model allows for simpler programming and is fast enough that the application's UI doesn't become unresponsive.

## How isolate works:
1. Each isolate has its own memory and its own event loop.
2. The event loop processes events in the order that they're added to an event queue.
3. On the main isolate, these events can be anything from handling a user tapping in the UI, to executing a function, to painting a frame on the screen.


## When and why to use isolats in flutter
### UI Jank:
UI jank refers to the lag or stutter in the user interface that occurs when the main isolate—the thread that handles UI rendering—becomes overloaded. In Flutter, the goal is to maintain a smooth, responsive experience by rendering at 60 frames per second (fps). Each frame should ideally take no more than 16 milliseconds.

However, when the main isolate is busy handling a heavy or time-consuming task, like processing large data files or applying complex image filters, it struggles to render each frame within that 16-millisecond window. As a result, it falls behind on rendering frames, and users experience this delay as lag or choppiness in the interface.
### Common Use Cases for Isolates:
1.Data Processing: Large data files, such as JSON, are best parsed in an isolate to avoid blocking the main isolate.
2.Image and Media Processing: Tasks like applying filters or resizing images are computationally expensive, so moving them to an isolate ensures the UI remains responsive.

3.Complex Computations: Calculations requiring significant CPU resources, like financial models or scientific computations, are good candidates for isolates.

## Virtual explanation of UI jank:

### UI Jank Due to Long Task on Main Isolate:
This chart shows the Frame Gap between expected and actual frame times. 
![image](https://github.com/JasonY0329/Isolates/blob/main/graphs/UI%20Jank%20Due%20to%20Long%20Task%20on%20Main%20Isolate.png)

The solid line represents the expected frame times (ideal rendering at 16ms intervals).

The dashed line represents actual frame times when a heavy task is blocking the main isolate.

The gray-shaded area highlights the frame gap, which causes visible lag.
### Expected vs. Actual Frame Time Gap
This chart further emphasizes the concept of frame delay.
![image](https://github.com/JasonY0329/Isolates/blob/main/graphs/Expected%20vs.%20Actual%20Frame%20Time%20Gap.png)
The red-shaded area represents a significant delay caused by the heavy task.

This delay results in a janky user experience.

### Why Use Isolates for Heavy Tasks?

By using isolates to handle CPU-intensive tasks, the main isolate can focus on rendering the UI smoothly and responding to user interactions in real-time. Isolates help prevent frame gaps, ensuring a smooth, responsive app experience.




## Message Passing and Communication Between Isolates

In Dart, isolates are an implementation of the Actor model, providing concurrent execution by running code in separate memory spaces. Unlike traditional threads, isolates do not share state or memory with each other, ensuring data safety and preventing race conditions. The primary method for communication between isolates is through message passing using Port objects, specifically SendPort and ReceivePort.

### Message Passing Mechanism:
When isolates need to communicate, they do so by sending messages. These messages are typically copied from the sending isolate to the receiving isolate to maintain isolation. This ensures that any data passed to an isolate remains unaffected by modifications in the originating isolate. Immutable objects, such as String or unmodifiable byte arrays, are an exception to this rule. They are passed by reference, which enhances performance without compromising the actor model’s behavior since immutable objects cannot be altered.

### Communication with Ports:
ReceivePort acts as the receiving channel for messages, similar to a listener, while SendPort functions like a sender. This setup resembles a stream where ReceivePort listens for incoming data and triggers a callback when a message is received. This structured message-passing ensures controlled and safe communication between isolates.

### Short-Lived Isolates:
Dart offers the Isolate.run() method as a simple way to execute short-lived tasks in a separate isolate. This method spawns a new isolate, runs a provided callback function, returns the result to the main isolate, and then shuts down. This process runs concurrently, preventing the main UI thread from becoming blocked.

```dart
Future<int> calculateSumInIsolate() async {
  return await Isolate.run(() {
    int sum = 0;
    for (int i = 0; i < 1000000; i++) {
      sum += i;
    }
    return sum;
  });
}

void main() async {
  int result = await calculateSumInIsolate();
  print('Sum from short-lived isolate: $result');
}
```

### Long-Lived Isolates:
For tasks that require continuous or repeated communication over time, Dart provides Isolate.spawn() along with ReceivePort and SendPort to facilitate long-term communication. These longer-lived isolates act as background workers and are useful for applications needing consistent interaction, such as data processing, parsing, or other CPU-intensive operations.

```dart
void longRunningTask(SendPort sendPort) {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort); // Send the port back to the main isolate

  receivePort.listen((message) {
    if (message == 'START') {
      int sum = 0;
      for (int i = 0; i < 1000000; i++) {
        sum += i;
      }
      sendPort.send('Sum from long-lived isolate: $sum');
      receivePort.close(); // Close after sending result
    }
  });
}

void main() async {
  ReceivePort mainReceivePort = ReceivePort(); // Main isolate's receive port
  await Isolate.spawn(longRunningTask, mainReceivePort.sendPort);

  mainReceivePort.listen((message) {
    if (message is SendPort) {
      message.send('START'); // Start the computation in the spawned isolate
    } else {
      print(message); // Print the result
      mainReceivePort.close(); // Close after receiving the result
    }
  });
}
```
