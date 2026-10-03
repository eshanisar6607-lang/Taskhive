TaskHive
TaskHive is a full-stack project management application that helps teams organize workspaces, projects, and tasks in one place. Members can collaborate through task assignments, comments, file uploads, workspace invitations, and notifications.
Features
- Register and log in with token-based authentication
- Create workspaces and manage workspace members
- Organize work into projects and tasks
- Assign tasks and track their status and priority
- Invite members to collaborate in a workspace
- Add comments and attach files to tasks
- View notifications about team activity
Technology
- Frontend: React, TypeScript, and Tailwind CSS
- Backend: ASP.NET Core 8 Web API and Entity Framework Core
- Database: Microsoft SQL Server
- Authentication: JSON Web Tokens (JWT)
Application flow
The frontend sends requests to the ASP.NET Core Web API. The API validates requests, applies application logic, and reads or updates information in SQL Server.
React frontend  →  ASP.NET Core Web API  →  SQL Server
Getting started
Prerequisites
- .NET 8 SDK
- Microsoft SQL Server
- Node.js and npm (for the React frontend)
Configure the backend
1. Open the backend project folder containing the .csproj file.
2. Configure the DefaultConnection connection string for your local SQL Server in your local development settings.
3. Configure the JWT settings required by the API. Keep real passwords, signing keys, and other secrets out of GitHub.
4. Restore packages and run the API:
dotnet restore
dotnet run
Use the local URL printed by the application to open the API. If Swagger is enabled, its page can be used to inspect and try the endpoints.
Run the frontend
Open the frontend project folder and run its development commands:
npm install
npm run dev
If the frontend uses a different start script, use the command defined in its package.json. Make sure its API base URL points to the local backend address.
Security
Do not commit database passwords, JWT signing keys, private configuration files, uploaded user files, or real user data. Add local secrets and development-only settings to .gitignore before pushing the project.
Project purpose
TaskHive was created as a learning and portfolio project to practice full-stack development, REST API integration, authentication, relational database design, and collaborative project workflows
