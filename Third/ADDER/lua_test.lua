for x=0,15 do
  for y=0,15 do
    sim.setinput("a", '16h' .. tostring(x))
    sim.setinput("a", '16h' .. tostring(y)) 
    sim.sleep(100)
    assert(tonumber(sim.getoutput("o"):tohex()) == (a + b) % 16,
    "Error: a=" .. a .. " b=" .. b)
  end
end
print("OK!")