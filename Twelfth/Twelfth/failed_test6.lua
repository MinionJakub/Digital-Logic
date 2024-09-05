sim.setinput("wr", 0)
sim.setinput("start", 0)
sim.setinput("nrst", 0)
sim.sleep(100)
sim.setinput("nrst",1)
sim.sleep(100)
assert(sim.getoutput("ready"):ishigh(), "Reset failed!")
sim.wait(sim.posedge("clk"))
sim.setinput("wr", 1)
arr = {29,161,221,224,226,25,208,15}
j = 0
for i = 0, 7 do
-- arr[i+1] = math.random(0, 255)
sim.setinput("addr", i)
sim.setinput("datain", arr[i+1])
sim.wait(sim.posedge("clk"))
end
sim.setinput("wr", 0)
sim.setinput("start", 1)
sim.wait(sim.posedge("clk"))
sim.setinput("start", 0)
sim.sleep(10)
assert(sim.getoutput("ready"):islow(), "Start failed!")
while sim.getoutput("ready"):islow() do
sim.wait(sim.posedge("clk"))
j = j + 1
sim.sleep(10)
end
table.sort(arr)
for i = 0, 7 do
sim.setinput("addr", i)
sim.wait(sim.posedge("clk"))
sim.sleep(10)
assert(sim.getoutput("dataout"):tointeger() == arr[i+1],
"Sorting failed!")
end
print("OK!")
print(j)