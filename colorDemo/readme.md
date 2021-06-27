## Color Demos

Uses VT100 control codes to set color and location of text, starting out with line-drawing functions, to box drawing, to text positioning and wrapping, to building a demo TUI frame. 

Still missing to be a functional TUI 
- using a readkey loop to capture user interaction with interface, then drawing on a loop (read-host locks the loop, read-host is therefor bad)
- Component array and int to hold selection index. Component composed of @(\[bool\] $invalidated, \[scriptblock\]{})? on enter, run $components\[$selected\]\[1\]?
- invalidation flag to advise drawloop to re-render a component on the screen, allowing sectional re-rendering instead of redrawing the whole screen

Download all files to the same folder then run . ./fullDemo.ps1 from that folder (cd as necessary first) to see all demos in action. Each builds on the last and imports the last to add the next layer of abstraction. Good way to dip your toes before diving headlong into madness.

![image](https://user-images.githubusercontent.com/33932119/123533477-07ff6e00-d6e4-11eb-8b13-702081a79f8c.png)
![image](https://user-images.githubusercontent.com/33932119/123533489-1b123e00-d6e4-11eb-86f9-7ac3b5f9bb2e.png)
