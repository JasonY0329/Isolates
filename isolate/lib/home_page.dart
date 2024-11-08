import 'package:flutter/material.dart';
import 'dart:isolate';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Image.asset('assets/gifs/loading.gif'), 
              //direct call
              ElevatedButton(
                onPressed: (){
                  var total = complexTask1();
                  debugPrint('Result 1: $total');
                }, 
                child: const Text('Task 1'),
              ),
              // Async
              ElevatedButton(
                onPressed: ()async{
                  var total = await complexTask2();
                  debugPrint('Result 1: $total');
                }, 
                child: const Text('Task 2'),
              ),
              // Isolate call with SnackBar alert
              // ElevatedButton widget that triggers a task in an isolate when pressed
              ElevatedButton(
                onPressed: () async {
                  // Create a ReceivePort to receive messages from the isolate
                  final receivePort = ReceivePort();

                  // Spawn a new isolate and pass the sendPort of receivePort to it.
                  // complexTask3 is the function that will run in the isolate.
                  // The isolate can send data back to this main isolate using receivePort's sendPort.
                  await Isolate.spawn(complexTask3, receivePort.sendPort);

                  // Listen for data (result) sent from the isolate on the receivePort
                  receivePort.listen((total) {
                    // Print the result received from the isolate to the console
                    debugPrint('Result 3: $total');

                    // Display a SnackBar with the result in the app's UI
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Isolate completed with result: $total'), // Display result text
                        duration: const Duration(seconds: 3), // Duration for which the SnackBar is visible
                        behavior: SnackBarBehavior.floating, // Make the SnackBar floating
                        margin: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0), // Margin around the SnackBar
                      ),
                    );

                    // Close the receive port to free resources once we have received the result
                    receivePort.close();
                  });
                },
                child: const Text('Task 3'), // Label for the button
              ),
            ],
          ),
        )),

    );
  }
    
}
double complexTask1()  {
    var total = 0.0;
    for (var i = 0; i < 1000000000; i++) {
      total += i;
    }
    return total;
}

//Async (Future/await): Supports concurrency, allowing the program to handle multiple tasks 
//without waiting for each task to complete sequentially. Suitable for tasks that involve waiting 
//because they can wait for the task to complete while other code continues to run. However, all async code in Dart runs 
//on a single thread (the main isolate), so it doesn't achieve parallelism. It simply schedules
//tasks to run one after the other, avoiding blocking the main thread.
Future<double> complexTask2() async {
    var total = 0.0;
    for (var i = 0; i < 1000000000; i++) {
      total += i;
    }
    return total;
}
//Isolate: Supports parallelism, meaning it can run tasks in truly separate threads. 
//An isolate has its own memory and runs independently, so it can process tasks simultaneously 
//with other isolates, fully utilizing multiple CPU cores.
complexTask3(SendPort sendPort) {
  var total = 0.0;
  for (var i = 0; i < 1000000000; i++) {
    total += i;
  }
  sendPort.send(total);
}