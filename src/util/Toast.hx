package util;

class Toast {
    static var queue:Array<String> = [];
    static var isDisplaying:Bool = false;

    public static function show(msg:String) {
        // Add the message to the queue
        queue.push(msg);
        // If not currently displaying a toast, start processing the queue
        if (!isDisplaying) {
            processQueue();
        }
    }

    static function processQueue() {
        if (queue.length == 0) {
            // No more toasts to display
            isDisplaying = false;
            return;
        }

        // Indicate that a toast is being displayed
        isDisplaying = true;

        // Get the next message from the queue
        var msg = queue.shift();

        // Create toast element
        var toast = js.Browser.document.createElement('div');
        toast.innerHTML = msg;
        toast.className = 'toast';

        // Apply basic styles
        toast.style.position = 'fixed';
        toast.style.bottom = '20px';
        toast.style.left = '50%';
        toast.style.transform = 'translateX(-50%)';
        toast.style.backgroundColor = '#333';
        toast.style.color = '#fff';
        toast.style.padding = '10px 20px';
        toast.style.borderRadius = '5px';
        toast.style.boxShadow = '0 0 10px rgba(0, 0, 0, 0.5)';
        toast.style.zIndex = '9999';
        toast.style.opacity = '0';
        toast.style.transition = 'opacity 0.5s';

        // Append to body
        js.Browser.document.body.appendChild(toast);

        // Show toast with fade-in effect
        haxe.Timer.delay(function() {
            toast.style.opacity = '1';
        }, 50);

        // Hide toast after 3 seconds with fade-out effect then remove from DOM
        haxe.Timer.delay(function() {
            toast.style.opacity = '0';
            haxe.Timer.delay(function() {
                if (toast.parentNode != null) {
                    toast.parentNode.removeChild(toast);
                }
                // After removing the current toast, process the next one in the queue
                processQueue();
            }, 500);
        }, 3000);
    }
}