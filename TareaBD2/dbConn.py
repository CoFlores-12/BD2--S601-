import pyodbc 
cnxn = pyodbc.connect('DRIVER={SQL server};Server=DESKTOP-7K3TP0O;DATABASE=test1;UID=prueba;PWD=12345;')

FirstName = 'as'
LastName = 'as'
email = '<EMAIL>'
password = '<PASSWORD>'
encryptKey = 'key'

cursor = cnxn.cursor()
cursor.execute("INSERT INTO dbo.users (FirstName,LastName,email,pass) VALUES (?,?,?,ENCRYPTBYPASSPHRASE(?,?))",(FirstName, LastName, email, encryptKey, password))
cnxn.commit()