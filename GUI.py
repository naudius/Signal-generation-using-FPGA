from tkinter import *
import tkinter.font as font
from tkinter import messagebox
import serial
import struct
import time
import sys
#--------------------------------------------------------------------------------#
#functions
def stopCommand():
    endFreqEnt.config(state= "normal")
    periodFreqEnt.config(state= "normal")
    startFreqEnt.config(state= "normal")
    with serial.Serial(port='COM6', baudrate=115200) as s:
        s.write(struct.pack('<BB',0xFF,0xFD))

def freqHigh():#function of the button
    tkinter.messagebox.showinfo("frequency too high")
    
def freqLow():#function of the button
    tkinter.messagebox.showinfo("frequency too low")

def periodLow():#function of the button
    tkinter.messagebox.showinfo("sweep period too low")

def startCommand():
    endFreqEnt.config(state= "disabled")
    periodFreqEnt.config(state= "disabled")
    startFreqEnt.config(state= "disabled")
    with serial.Serial(port='COM6', baudrate=115200) as s:
        if (mode == "Saw"):
            end = int(endFreqEnt.get())
            if (end> 30000) :
               freqHigh()
            start = int(startFreqEnt.get())
            if (start < 120) :
               freqLow()
            Tm = int(periodFreqEnt.get())
            if (Tm < 4.078) :
                periodLow()
            Tm = Tm/4.078
            startStep = round(start*2048*0.000004078)
            endStep = round(end*2048*0.000004078)
            freqMod = round((endStep-startStep)/Tm)
            print(startStep,endStep,freqMod)
            s.write(struct.pack('<BBBBB',0xFF,0x00,startStep,endStep,freqMod))
            
        if (mode == "Triangle"):
            end = int(endFreqEnt.get())
            if (end> 30000) :
               freqHigh()
            start = int(startFreqEnt.get())
            if (start < 120) :
               freqLow()
            Tm = int(periodFreqEnt.get())
            if (Tm < 4.078) :
                periodLow()
            Tm = Tm/4.078
            startStep = round(start*2048*0.000004078)
            endStep = round(end*2048*0.000004078)
            freqMod = round((endStep-startStep)/Tm)
            print(startStep,endStep,freqMod,"Tri")
            s.write(struct.pack('<BBBBB',0xFF,0xFE,startStep,endStep,freqMod))
        return 

    return 
        
    
def modeTraingle():
    global mode
    mode = "Triangle"
    return
    
def modeSaw():
    global mode 
    mode = "Saw"
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
r1=Radiobutton(mFrame, text='Traingle sweep', variable=var, value=1,width=14,command=modeTraingle).grid(row=0,column=0) 
r2=Radiobutton(mFrame, text='Sawtooth sweep', variable=var, value=2,width=14,command=modeSaw).grid(row=0,column=1)

#--------------------------------------------------------------------------------#
#frequency sweep
fsLf=LabelFrame(win,text="Frequency Sweep")
fsLf.place(x=5,y=90,height=110,width=275)

startFreqLab=Label(fsLf,text='Start frequency (Hz):')
startFreqLab.place(x=5, y=0)

endFreqLab=Label(fsLf,text='End frequency (Hz):  ')
endFreqLab.place(x=5, y=30)

startFreqLab=Label(fsLf,text='Sweep period (us):')
startFreqLab.place(x=5, y=60)

startFreqEnt = Entry(fsLf) 
startFreqEnt.place(x=120, y=0) 

endFreqEnt = Entry(fsLf) 
endFreqEnt.place(x=120, y=30)

periodFreqEnt = Entry(fsLf) 
periodFreqEnt.place(x=120, y=60)
 
#------------------------------------------------------------------------------#
#button
fsBtn = Button(win, text="run", command=startCommand)
fsBtn.place(x=50,y=250,width=100)
#------------------------------------------------------------------------------#
#button
endBtn = Button(win, text="Stop", command=stopCommand)
endBtn.place(x=150,y=250,width=100)
#------------------------------------------------------------------------------#
#main loop

win.mainloop() #running the loop that works as a trigger