from tkinter import *
import tkinter.font as font
from tkinter import messagebox
#--------------------------------------------------------------------------------#
#functions
def fsCommand():
    end = endFreqEnt.get()
    start = startFreqEnt.get()
    return messagebox.showinfo('message',f"Start frequency: {start} \n End frequency: {end}")
    
def modeSingle():
    singleFreqEnt.config(state= "normal")
    endFreqEnt.config(state= "disabled")
    startFreqEnt.config(state= "disabled")
    return
    
def modeSweep():
    endFreqEnt.config(state= "normal")
    startFreqEnt.config(state= "normal")
    singleFreqEnt.config(state= "disabled")
    return


    
#--------------------------------------------------------------------------------#
#main window
win=Tk() #creating the main window and storing the window object in 'win'
win.title('Signal control') #setting title of the window
win.geometry('285x280') #setting the size of the window
win.configure(bg="#E9F3E8")
#--------------------------------------------------------------------------------#
#fonts
headingFont = font.Font(size=9,weight="bold")
#--------------------------------------------------------------------------------#
#title
tFrame = LabelFrame(win)
tFrame.place(x=5,y=1,height =25,width=275)
title=Label(tFrame,text='Signal specifications',width=20)
title.pack()
#--------------------------------------------------------------------------------#
#Mode
mFrame = LabelFrame(win,text="Mode")
mFrame.place(x=5,y=25,height=50,width=275)
var = IntVar() 
r1=Radiobutton(mFrame, text='Single frequency', variable=var, value=1,width=14,command=modeSingle).grid(row=0,column=0) 
r2=Radiobutton(mFrame, text='Frequency sweep', variable=var, value=2,width=14,command=modeSweep).grid(row=0,column=1)
#--------------------------------------------------------------------------------#
#Amplitude 
gLabel=LabelFrame(win,text="General")
gLabel.place(x=5,y=75,height = 50,width=275)

amplitudeLab=Label(gLabel,text='Amplitude:')
amplitudeLab.place(x=5,y=0)

sb = Spinbox(gLabel, from_ = 1, to = 5) 
sb.place(x=100,y=0)

#--------------------------------------------------------------------------------#
#frequency sweep
fsLf=LabelFrame(win,text="Frequency Sweep")
fsLf.place(x=5,y=125,height=75,width=275)

startFreqLab=Label(fsLf,text='Start frequency:')
startFreqLab.place(x=5, y=0)

endFreqLab=Label(fsLf,text='End frequency:  ')
endFreqLab.place(x=5, y=30)

startFreqEnt = Entry(fsLf) 
startFreqEnt.place(x=100, y=0) 

endFreqEnt = Entry(fsLf) 
endFreqEnt.place(x=100, y=30)

endFreqEnt.config(state= "disabled")
startFreqEnt.config(state= "disabled")
#-------------------------------------------------------------------------------#
#single frequency
sfLf=LabelFrame(win,text="Single Frequency")
sfLf.place(x=5,y=200,height=50,width=275)

singleFreqLab=Label(sfLf,text='Frequency:')
singleFreqLab.place(x=5, y=0)

singleFreqEnt = Entry(sfLf) 
singleFreqEnt.place(x=100, y=0)
singleFreqEnt.config(state= "disabled")
 
#------------------------------------------------------------------------------#
#button
fsBtn = Button(win, text="run", command=fsCommand)
fsBtn.place(x=100,y=250,width=100)
#------------------------------------------------------------------------------#
#main loop

win.mainloop() #running the loop that works as a trigger