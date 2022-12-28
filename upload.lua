local TOKEN = "LcslDOmQVzpqvgviuoBS37BykW5BPqE4"
local baseUrl = "https://cc-my-scripts.cyclic.app/"


function readFile()
  print("Reading log.txt...\n")
  local file = fs.open("log.txt", "r")
  local output = ""
  local line = file.readLine()
  while line do
    output = output .. line .. "\n"
    line = file.readLine()
  end
  file.close()
  return output
end

function createLog()
  print("Sending log data to server...\n")
  local logData = readFile()
  local body = textutils.serializeJSON({logData = logData})
  local response = http.post(baseUrl .. '/farmland/log', body,
  {
      ['Content-Type'] = 'application/json',
      ['Authorization'] = "Bearer " .. TOKEN

  })
  local code = response.getResponseCode()
    print("Response from server:")
  if code == 200 then
      term.setTextColor(colors.green)
      print(response.readAll())
  else
      term.setTextColor(colors.red)
      print(response.readAll())
  end
      term.setTextColor(colors.white)

end

createLog()