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


###How Isolates Work and Communication Mechanisms
Dart's isolates are an implementation of the Actor model. They can only communicate with each other by message passing, which is done with Port objects. When messages are "passed" between each other, they are generally copied from the sending isolate to the receiving isolate. This means that any value passed to an isolate, even if mutated on that isolate, doesn't change the value on the original isolate.

The only objects that aren't copied when passed to an isolate are immutable objects that can't be changed anyway, such a String or an unmodifiable byte. When you pass an immutable object between isolates, a reference to that object is sent across the port, rather than the object being copied, for better performance. Because immutable objects can't be updated, this effectively retains the actor model behavior.

An exception to this rule is when an isolate exits when it sends a message using the Isolate.exit method. Because the sending isolate won't exist after sending the message, it can pass ownership of the message from one isolate to the other, ensuring that only one isolate can access the message.

The two lowest-level primitives that send messages are SendPort.send, which makes a copy of a mutable message as it sends, and Isolate.exit, which sends the reference to the message. Both Isolate.run and compute use Isolate.exit under the hood.

The easiest way to move a process to an isolate in Flutter is with the Isolate.run method. This method spawns an isolate, passes a callback to the spawned isolate to start some computation, returns a value from the computation, and then shuts the isolate down when the computation is complete. This all happens concurrently with the main isolate, and doesn't block it.

The Isolate.run method requires a single argument, a callback function, that is run on the new isolate. This callback's function signature must have exactly one required, unnamed argument. When the computation completes, it returns the callback's value back to the main isolate, and exits the spawned isolate.

For example, consider this code that loads a large JSON blob from a file, and converts that JSON into custom Dart objects. If the json decoding process wasn't off loaded to a new isolate, this method would cause the UI to become unresponsive for several seconds.


Set up long-lived communication between isolates with two classes (in addition to Isolate): ReceivePort and SendPort. These ports are the only way isolates can communicate with each other.

Ports behave similarly to Streams, in which the StreamController or Sink is created in one isolate, and the listener is set up in the other isolate. In this analogy, the StreamConroller is called a SendPort, and you can "add" messages with the send() method. ReceivePorts are the listeners, and when these listeners receive a new message, they call a provided callback with the message as an argument.

For an in-depth explanation on setting up two-way communication between the main isolate and a worker isolate, follow the examples in the Dart documentation.
