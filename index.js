exports.handler = async (event) => {
  const response = {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello from Waldo World!' })
  }
  console.log(response)
  return response
}
