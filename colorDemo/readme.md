## Color Demos

Uses VT100 control codes to set color and location of text, starting out with line-drawing functions, to box drawing, to text positioning and wrapping, to building a demo TUI frame. 

Still missing to be a functional TUI 
- using a readkey loop to capture user interaction with interface, then drawing on a loop
- Component array and int to hold position
- invalidation flag to advise drawloop to re-render a component on the screen, allowing sectional re-rendering instead of redrawing the whole screen

Download all files to the same folder then run . ./fullDemo.ps1 from that folder (cd as necessary first) to see all demos in action. Each builds on the last and imports the last to add the next layer of abstraction. Good way to dip your toes before diving headlong into madness.
