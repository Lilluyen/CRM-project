    package controller.tasks;

    import java.io.IOException;
    import java.sql.Connection;
    import java.time.LocalDate;

    import dao.TaskDAO;
    import jakarta.servlet.ServletException;
    import jakarta.servlet.annotation.WebServlet;
    import jakarta.servlet.http.HttpServlet;
    import jakarta.servlet.http.HttpServletRequest;
    import jakarta.servlet.http.HttpServletResponse;
    import model.Task;
    import util.DBContext;

    @WebServlet(name = "CreateTask", urlPatterns = { "/tasks/create" })
    public class CreateTask extends HttpServlet {

        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            try {
                // Get parameters from request
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                String relatedType = "customer";
                int relatedId = 1;
                int assignedTo = Integer.parseInt(request.getParameter("assignedTo"));
                String priority = request.getParameter("priority");
                String status = request.getParameter("status");
                String dueDateStr = request.getParameter("dueDate");

                // Create Task object
                Task task = new Task();
                task.setTitle(title);
                task.setDescription(description);
                task.setRelatedType(relatedType);
                task.setRelatedId(relatedId);
                task.setAssignedTo(assignedTo);
                task.setPriority(priority);
                task.setStatus(status != null ? status : "PENDING");
                task.setDueDate(LocalDate.parse(dueDateStr));

                // Persist to database
                Connection connection = DBContext.getConnection();
                TaskDAO taskDAO = new TaskDAO(connection);

                boolean success = taskDAO.createTask(task);

                if (success) {
                    request.setAttribute("message", "Task created successfully!");
                    request.getRequestDispatcher("/view/success.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Failed to create task!");
                    request.getRequestDispatcher("/view/error/500.jsp").forward(request, response);
                }

                connection.close();
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Error: " + e.getMessage());
                try {
                    request.getRequestDispatcher("/view/error/500.jsp").forward(request, response);
                } catch (ServletException | IOException ex) {
                    ex.printStackTrace();
                }
            }
        }

        @Override
        protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
            req.setAttribute("mode", "create");
            req.getRequestDispatcher("/view/tasks/task-form.jsp").forward(req, resp);
        }

    }
