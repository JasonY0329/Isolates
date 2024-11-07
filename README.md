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
