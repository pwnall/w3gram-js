# W3gram exports a singleton implementing the ServiceWorkerRegistration
# interface.
W3gram = new ServiceWorkerRegistration()

# The ServiceWorkerRegistration class is defined before W3gram is available, so
# we attach it to W3gram object here.
W3gram.ServiceWorkerRegistration = ServiceWorkerRegistration

# Namespace for implementation-internal classes.
W3gram._ = {}
