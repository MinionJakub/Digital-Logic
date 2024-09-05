t = ">++++++++[<+++++++++>-]<."
f = open("program.vh", "w")
for c in t: f.write("%x " % ord(c))
f.close()