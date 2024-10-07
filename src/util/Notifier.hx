package util;

class Notifier {
    static var container:Dynamic; 

    public static function init() {
        
        if (container == null) {
            container = js.Browser.document.createElement('div');
            container.className = 'notification-container';

            
            container.style.position = 'fixed';
            container.style.bottom = '20px'; 
            container.style.right = '20px'; 
            container.style.display = 'flex';
            container.style.flexDirection = 'column'; 
            container.style.alignItems = 'flex-end'; 
            container.style.justifyContent = 'flex-end'; 
            container.style.pointerEvents = 'none'; 
            container.style.zIndex = '9999';

            
            js.Browser.document.body.appendChild(container);
        }
    }

    public static function notify(msg:String) {
        init(); 

        
        var existingNotifications = [];
        for (i in 0...container.children.length) {
            var el = container.children[i];
            existingNotifications.push(el);
        }

        
        var initialPositions = [];
        for (el in existingNotifications) {
            var rect = el.getBoundingClientRect();
            initialPositions.push({ el: el, top: rect.top });
        }

        
        var notification = js.Browser.document.createElement('div');
        notification.innerHTML = msg;
        notification.className = 'notification';

        
        notification.style.backgroundColor = '#333';
        notification.style.color = '#fff';
        notification.style.padding = '10px 20px';
        notification.style.borderRadius = '5px';
        notification.style.boxShadow = '0 0 10px rgba(0, 0, 0, 0.5)';
        notification.style.marginTop = '10px'; 
        notification.style.opacity = '0';
        notification.style.transition = 'opacity 0.5s, transform 0.5s';
        notification.style.pointerEvents = 'auto'; 

        
        container.appendChild(notification);

        
        var finalPositions = [];
        var allNotifications = [];
        for (i in 0...container.children.length) {
            var el = container.children[i];
            allNotifications.push(el);
            var rect = el.getBoundingClientRect();
            finalPositions.push({ el: el, top: rect.top });
        }

        
        for (i in 0...existingNotifications.length) {
            var el = existingNotifications[i];
            var initialTop = initialPositions[i].top;
            var finalTop = finalPositions[i].top;
            var deltaY = initialTop - finalTop;

            
            el.style.transition = 'transform 0s';
            el.style.transform = 'translateY(' + deltaY + 'px)';
        }

        
        
        var css = js.Browser.window.getComputedStyle(container).opacity;

        
        for (el in existingNotifications) {
            el.style.transition = 'transform 0.5s';
            el.style.transform = 'translateY(0)';
        }

        
        haxe.Timer.delay(function() {
            notification.style.opacity = '1';
        }, 50);

        
        haxe.Timer.delay(function() {
            notification.style.opacity = '0';
            haxe.Timer.delay(function() {
                if (notification.parentNode != null) {
                    notification.parentNode.removeChild(notification);
                }
            }, 500);
        }, 3000);
    }
}