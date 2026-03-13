/**
 * TaskNotificationClient.js
 * Client-side utility for real-time task notifications
 * Usage:
 *   let client = new TaskNotificationClient(userId);
 *   client.connect();
 *   client.onNotification = function(data) { console.log('Received:', data); };
 */

class TaskNotificationClient {
    constructor(userId) {
        this.userId = userId;
        this.ws = null;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 5;
        this.reconnectDelay = 3000;
        this.isConnected = false;
        this.onNotification = null;
        this.onConnect = null;
        this.onDisconnect = null;
        this.onError = null;
        this.messageQueue = [];
    }

    /**
     * Connect to WebSocket server
     */
    connect() {
        try {
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = `${protocol}//${window.location.host}/CRM-project/ws/notifications/${this.userId}`;
            
            this.ws = new WebSocket(wsUrl);
            
            this.ws.onopen = () => this.handleOpen();
            this.ws.onmessage = (event) => this.handleMessage(event);
            this.ws.onclose = () => this.handleClose();
            this.ws.onerror = (error) => this.handleError(error);
        } catch (error) {
            console.error('WebSocket connection error:', error);
            this.attemptReconnect();
        }
    }

    /**
     * Handle WebSocket open
     */
    handleOpen() {
        this.isConnected = true;
        this.reconnectAttempts = 0;
        console.log('Connected to task notifications');
        
        if (this.onConnect) {
            this.onConnect();
        }
        
        // Send queued messages
        while (this.messageQueue.length > 0) {
            const message = this.messageQueue.shift();
            this.send(message);
        }
        
        // Start heartbeat
        this.startHeartbeat();
    }

    /**
     * Handle incoming messages
     */
    handleMessage(event) {
        try {
            const data = JSON.parse(event.data);
            console.log('Notification received:', data);
            
            if (this.onNotification) {
                this.onNotification(data);
            }
            
            // Handle specific notification types
            switch (data.type) {
                case 'task_assigned':
                    this.handleTaskAssigned(data);
                    break;
                case 'task_status_changed':
                    this.handleTaskStatusChanged(data);
                    break;
                case 'connected':
                    console.log('Connected message:', data.message);
                    break;
            }
        } catch (error) {
            console.error('Error processing message:', error);
        }
    }

    /**
     * Handle task assigned notification
     */
    handleTaskAssigned(data) {
        const message = `New task assigned: ${data.taskTitle} (ID: ${data.taskId})`;
        this.showNotification('Task Assigned', message, 'info');
    }

    /**
     * Handle task status change notification
     */
    handleTaskStatusChanged(data) {
        const message = `Task "${data.taskTitle}" status changed to: ${data.newStatus}`;
        this.showNotification('Task Updated', message, 'info');
    }

    /**
     * Handle WebSocket close
     */
    handleClose() {
        this.isConnected = false;
        console.log('Disconnected from task notifications');
        
        if (this.onDisconnect) {
            this.onDisconnect();
        }
        
        this.stopHeartbeat();
        this.attemptReconnect();
    }

    /**
     * Handle WebSocket error
     */
    handleError(error) {
        console.error('WebSocket error:', error);
        
        if (this.onError) {
            this.onError(error);
        }
    }

    /**
     * Send message to server
     */
    send(data) {
        if (this.isConnected && this.ws) {
            try {
                this.ws.send(JSON.stringify(data));
            } catch (error) {
                console.error('Error sending message:', error);
                this.messageQueue.push(data);
            }
        } else {
            this.messageQueue.push(data);
            console.warn('WebSocket not connected. Message queued.');
        }
    }

    /**
     * Send ping to server
     */
    ping() {
        this.send({ action: 'ping' });
    }

    /**
     * Start heartbeat to keep connection alive
     */
    startHeartbeat() {
        this.heartbeatInterval = setInterval(() => {
            if (this.isConnected) {
                this.send({ action: 'heartbeat' });
            }
        }, 30000); // Send heartbeat every 30 seconds
    }

    /**
     * Stop heartbeat
     */
    stopHeartbeat() {
        if (this.heartbeatInterval) {
            clearInterval(this.heartbeatInterval);
        }
    }

    /**
     * Attempt to reconnect to WebSocket
     */
    attemptReconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            console.log(`Attempting to reconnect (${this.reconnectAttempts}/${this.maxReconnectAttempts})...`);
            setTimeout(() => this.connect(), this.reconnectDelay);
        } else {
            console.error('Max reconnection attempts reached');
        }
    }

    /**
     * Disconnect from WebSocket
     */
    disconnect() {
        this.stopHeartbeat();
        if (this.ws) {
            this.ws.close();
        }
    }

    /**
     * Show browser notification
     */
    showNotification(title, message, type = 'info') {
        // Desktop notification if available
        if ('Notification' in window && Notification.permission === 'granted') {
            new Notification(title, {
                body: message,
                icon: '/CRM-project/images/notification-icon.png'
            });
        }
        
        // Also log to console
        console.log(`[${type.toUpperCase()}] ${title}: ${message}`);
    }

    /**
     * Request permission for desktop notifications
     */
    static requestNotificationPermission() {
        if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission();
        }
    }
}

/**
 * REST API client for task notifications
 */
class TaskNotificationAPIClient {
    constructor(baseUrl = '/crm/api/tasks') {
        this.baseUrl = baseUrl;
    }

    /**
     * Get all tasks assigned to a user
     */
    async getAssignedTasks(userId) {
        try {
            const response = await fetch(`${this.baseUrl}/notifications?userId=${userId}`);
            return await response.json();
        } catch (error) {
            console.error('Error fetching assigned tasks:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Send a notification
     */
    async sendNotification(userId, title, content) {
        try {
            const response = await fetch(`${this.baseUrl}/notifications`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `userId=${userId}&title=${encodeURIComponent(title)}&content=${encodeURIComponent(content)}`
            });
            return await response.json();
        } catch (error) {
            console.error('Error sending notification:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Update task status with notification
     */
    async updateTaskStatus(taskId, newStatus) {
        try {
            const response = await fetch(`${this.baseUrl}/update-status`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `taskId=${taskId}&status=${encodeURIComponent(newStatus)}`
            });
            return await response.json();
        } catch (error) {
            console.error('Error updating task status:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Get task status
     */
    async getTaskStatus(taskId) {
        try {
            const response = await fetch(`${this.baseUrl}/${taskId}/status`);
            return await response.json();
        } catch (error) {
            console.error('Error fetching task status:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Mark notification as read
     */
    async markNotificationAsRead(notificationId) {
        try {
            const response = await fetch(`${this.baseUrl}/notifications?action=mark-read&notificationId=${notificationId}`, {
                method: 'PUT'
            });
            return await response.json();
        } catch (error) {
            console.error('Error marking notification as read:', error);
            return { success: false, error: error.message };
        }
    }
}
