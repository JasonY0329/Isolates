# Isolates
Part 2:
UI Jank:
Define UI jank as the lag that occurs when the main isolate is overloaded and can’t render at a consistent frame rate. In Flutter, the goal is to render at 60 fps, meaning each frame should ideally take no more than 16ms.
When a heavy task exceeds this limit, it delays rendering, resulting in visible lag or frame drops.
Common Use Cases for Isolates:
Data Processing: Large data files, such as JSON, are best parsed in an isolate to avoid blocking the main isolate.
Image and Media Processing: Tasks like applying filters or resizing images are computationally expensive, so moving them to an isolate ensures the UI remains responsive.
Complex Computations: Calculations requiring significant CPU resources, like financial models or scientific computations, are good candidates for isolates.
![image](https://github.com/JasonY0329/Isolates/blob/main/graphs/UI%20Jank.png)



## Message Passing and Communication Between Isolates

### Introduction to Isolates:
In Dart, isolates are an implementation of the Actor model, providing concurrent execution by running code in separate memory spaces. Unlike traditional threads, isolates do not share state or memory with each other, ensuring data safety and preventing race conditions. The primary method for communication between isolates is through message passing using Port objects, specifically SendPort and ReceivePort.

### Message Passing Mechanism:
When isolates need to communicate, they do so by sending messages. These messages are typically copied from the sending isolate to the receiving isolate to maintain isolation. This ensures that any data passed to an isolate remains unaffected by modifications in the originating isolate. Immutable objects, such as String or unmodifiable byte arrays, are an exception to this rule. They are passed by reference, which enhances performance without compromising the actor model’s behavior since immutable objects cannot be altered.

### Special Cases with Isolate Exit:
An exception to the standard message copying rule occurs when an isolate sends a message using the Isolate.exit() method. In this case, ownership of the message is transferred, allowing the receiving isolate to access it directly as the sending isolate ceases to exist. This approach ensures that only one isolate has access to the message at any time.

### Low-Level Primitives for Message Passing:

	•	SendPort.send(): Used to send a copy of a message from one isolate to another.
	•	Isolate.exit(): Transfers message ownership, allowing efficient communication when the sending isolate exits.

### Short-Lived Isolates:
Dart offers the Isolate.run() method as a simple way to execute short-lived tasks in a separate isolate. This method spawns a new isolate, runs a provided callback function, returns the result to the main isolate, and then shuts down. This process runs concurrently, preventing the main UI thread from becoming blocked.

### Long-Lived Isolates:
For tasks that require continuous or repeated communication over time, Dart provides Isolate.spawn() along with ReceivePort and SendPort to facilitate long-term communication. These longer-lived isolates act as background workers and are useful for applications needing consistent interaction, such as data processing, parsing, or other CPU-intensive operations.

### Communication with Ports:
ReceivePort acts as the receiving channel for messages, similar to a listener, while SendPort functions like a sender. This setup resembles a stream where ReceivePort listens for incoming data and triggers a callback when a message is received. This structured message-passing ensures controlled and safe communication between isolates.
