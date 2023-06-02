const sqlText = args[0]
const resourceId = args[1]

const response = await Functions.makeHttpRequest({
  url: "https://hackathon.spaceandtime.dev/v1/sql/dql",
  method: "POST",
  timeout: 9000,
  headers: {
    Authorization: `Bearer eyJ0eXBlIjoiYWNjZXNzIiwia2lkIjoiNGE2NTUwNjYtZTMyMS00NWFjLThiZWMtZDViYzg4ZWUzYTIzIiwiYWxnIjoiRVMyNTYifQ.eyJpYXQiOjE2ODU3MDM0ODcsIm5iZiI6MTY4NTcwMzQ4NywiZXhwIjoxNjg1NzA0OTg3LCJ0eXBlIjoiYWNjZXNzIiwidXNlciI6IjhiNTUyMzU3LTBhNzMtNDI3OC1hNjZkLWZjZTk0NmFkNDY2MSIsInN1YnNjcmlwdGlvbiI6IjhiNTUyMzU3LTBhNzMtNDI3OC1hNjZkLWZjZTk0NmFkNDY2MSIsInNlc3Npb24iOiI3MWQ0NTBlNjRhMjZmZGE1ZGJhYmM4MmIiLCJzc25fZXhwIjoxNjg1Nzg5ODg3NzQxLCJpdGVyYXRpb24iOiI3YTliMzRiMWY1ZWI0NmQzMTBhODk4N2UifQ.KRN0cgiDS27sHC9x543xGXSgfojled9bUU5dF0fRpe7ZbrYZlHTJx-khrEFORPsX4Jeodkhs8mKnVTavBTnYqA`,
    "Content-Type": "application/json",
  },
  data: {
    resourceId: resourceId,
    sqlText: sqlText,
    biscuits: [
      `EqcBCj0KDnN4dDpjYXBhYmlsaXR5CgpkZGxfY3JlYXRlCgxhaTEzMDEuZGF0YTMYAyIPCg0IgAgSAxiBCBIDGIIIEiQIABIgUMk90nrVJE6FCp8FhM7gFbYBOGxyjg37uqRCKh4SO8kaQMfznr6JtyDqdyCvgu4pxVJYm000T11EJJ_clAJ9puv_y38YbW012zyfcOjbfWDuxuRSogIHanno3ijJeCck4wkiIgogkA_TKv6fefyuHtCt8mVKRXhaa8Lsi4QE-M3Yz8to_R4=`,
    ],
  },
})

const responseData = response.data
const arrayResponse = Object.keys(responseData[0]).map((key) => `${responseData[0][key]}`)

return Functions.encodeUint256(parseInt(arrayResponse[0]))
