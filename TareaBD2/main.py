import customtkinter
import pyodbc 

cursor = None
cnxn = None
encryptKey = "key" 

customtkinter.set_appearance_mode("dark")
 
def windowUsers():
    class Table:
        def __init__(self,roott):
            for i in range(total_rows):
                for j in range(total_columns):
                    self.e = customtkinter.CTkEntry(roott, width=100)
                    self.e.grid(row=i, column=j)
                    self.e.insert(customtkinter.END, lst[i][j])
    global cursor
    usersRoot = customtkinter.CTk()
    usersRoot.title("Usuarios")
    usersRoot.geometry("500x400")
    usersRoot.resizable(0, 0)
    if cursor == None:
        print(cursor)
        return
    lst = cursor.execute('SELECT [userid],[LastName],[FirstName],[email],CAST(DECRYPTBYPASSPHRASE(\''+encryptKey+'\',[pass]) AS varchar(255)) FROM [dbo].[users]')
    lst = lst.fetchall()
    total_rows = len(lst)
    total_columns = len(lst[0])
    t = Table(usersRoot)
    usersRoot.mainloop()

root = customtkinter.CTk()
root.geometry("400x400")
root.title("IS601 BD2")

nombreInput = customtkinter.CTkEntry(
                    master=root, 
                    width=120,
                    placeholder_text="Nombre")
nombreInput.pack(padx=20, pady=10)
nombreInput.place(relx=0.3,rely=0.2, anchor=customtkinter.CENTER)

apellidoInput = customtkinter.CTkEntry(
                    master=root,
                    width=120, 
                    placeholder_text="Apellido")
apellidoInput.pack(padx=20, pady=10)
apellidoInput.place(relx=0.7,rely=0.2, anchor=customtkinter.CENTER)


correoInput = customtkinter.CTkEntry(
                    master=root,
                    width=280, 
                    placeholder_text="Correo")
correoInput.pack(padx=20, pady=10)
correoInput.place(relx=0.5,rely=0.4, anchor=customtkinter.CENTER)

passwordInput = customtkinter.CTkEntry(
                    master=root,
                    width=280,
                    show="*", 
                    placeholder_text="Contraseña")
passwordInput.pack(padx=20, pady=10)
passwordInput.place(relx=0.5,rely=0.6, anchor=customtkinter.CENTER)

def saveUser():
    global cnxn
    global cursor
    FirstName = nombreInput.get()
    LastName = apellidoInput.get()
    email = correoInput.get()
    password = passwordInput.get()
    nombreInput.delete(0,customtkinter.END)
    apellidoInput.delete(0,customtkinter.END)
    correoInput.delete(0,customtkinter.END)
    passwordInput.delete(0,customtkinter.END)
    if cursor == None:
        return
    cursor.execute("INSERT INTO dbo.users (FirstName,LastName,email,pass) VALUES (?,?,?,ENCRYPTBYPASSPHRASE(?,?))",(FirstName, LastName, email, encryptKey, password))
    cnxn.commit()

button = customtkinter.CTkButton(
                master=root, 
                text="Save",
                fg_color="green",
                command=saveUser)
button.place(relx=0.3,rely=0.8, anchor=customtkinter.CENTER)

buttonUsers = customtkinter.CTkButton(
                master=root, 
                text="See Users",
                command=windowUsers)
buttonUsers.place(relx=0.7,rely=0.8, anchor=customtkinter.CENTER)

rootL = customtkinter.CTk()
rootL.geometry("250x250")
rootL.title("IS601 BD2")

serverInput = customtkinter.CTkEntry(
                    master=rootL, 
                    width=200,
                    placeholder_text="Server")
serverInput.pack(padx=20, pady=10)
serverInput.place(relx=0.5,rely=0.1, anchor=customtkinter.CENTER)

databaseInput = customtkinter.CTkEntry(
                    master=rootL, 
                    width=200,
                    placeholder_text="Database")
databaseInput.pack(padx=20, pady=10)
databaseInput.place(relx=0.5,rely=0.3, anchor=customtkinter.CENTER)

userdatabaseInput = customtkinter.CTkEntry(
                    master=rootL, 
                    width=200,
                    placeholder_text="User")
userdatabaseInput.pack(padx=20, pady=10)
userdatabaseInput.place(relx=0.5,rely=0.5, anchor=customtkinter.CENTER)

passdatabaseInput = customtkinter.CTkEntry(
                    master=rootL, 
                    width=200,
                    placeholder_text="Password")
passdatabaseInput.pack(padx=20, pady=10)
passdatabaseInput.place(relx=0.5,rely=0.7, anchor=customtkinter.CENTER)

def rootView():
    server = serverInput.get()
    database = databaseInput.get()
    user = userdatabaseInput.get()
    passw = passdatabaseInput.get()
    global cnxnx
    global cursor
    global root
    global rootL
    try:
        if server == "":
            global cnxn
            cnxn = pyodbc.connect('DRIVER={SQL server};Server=DESKTOP-7K3TP0O;DATABASE=test1;UID=prueba;PWD=12345;')
        else:
            cnxn = pyodbc.connect('DRIVER={SQL server};Server=' + server + ';DATABASE=' + database + ';UID=' + user + ';PWD=' + passw + ';')
        cursor = cnxn.cursor()
        print(cnxn)
        rootL.destroy()
        root.mainloop()
    except:
        cursor = None
        cnxn = None

buttonRoot = customtkinter.CTkButton(
                master=rootL, 
                text="Connect",
                command=rootView)
buttonRoot.place(relx=0.5,rely=0.9, anchor=customtkinter.CENTER)

rootL.mainloop()