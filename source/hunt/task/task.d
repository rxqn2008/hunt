module hunt.task.task;

import core.time;
import std.stdio;
import std.parallelism;
import std.variant;
import core.atomic;
import std.traits;
import std.exception;
import core.sync.rwmutex;

import kiss.event.EventLoop;
import kiss.core;
import kiss.util.timer;
import kiss.logger;

enum TaskStatus : ubyte
{
    IDLE,
    RUNNING,
    FINISH,
    CANCEL,
    INVAILD,
}

class Task
{

    this()
    {
        _taskid = toHash();
    }

    void exec()
    {
        trace("please override the 'exec' function !");
    }

protected:
    final void setInterval(Duration d)
    {
        _interval = d;
    }

    @property Duration interval()
    {
        return _interval;
    }

    @property size_t tid()
    {
        return _taskid;
    }

    @property TaskStatus status()
    {
        return atomicLoad(_status);
    }

    final void setStatus(TaskStatus ts)
    {
        atomicStore(_status, ts);
    }

    @property bool cancel()
    {
        if (atomicLoad(_status) == TaskStatus.RUNNING)
            return false;
        atomicStore(_status, TaskStatus.CANCEL);
        return true;
    }

private:
    Duration _interval;
    size_t _taskid;
    shared TaskStatus _status = TaskStatus.IDLE;
}

class TaskManager
{
private:
    EventLoop _taskLoop;
    Task[size_t] _tasks;
    ReadWriteMutex _mutex;

public :
    this()
    {      
        _mutex = new ReadWriteMutex();
    }

    ~this()
    {
        _mutex.destroy;
    }

    void setEventLoop(EventLoop el)
    {
        _taskLoop = el;
    }
public:

    void run()
    {
        _taskLoop.run();
    }

    static void doJob(Task t)
    {
        trace("--do job ---: ", t.tid);
        t.exec();
        auto interval = cast(size_t) t.interval.total!("msecs");
        if (interval == 0)
        {
            GetTaskMObject().del(t.tid);
        }
    }

    size_t put(Task t, Duration d = 0.seconds)
    {
        t.setInterval(d);
        add(t);
        if (d.total!"seconds" == 0)
        {
            taskPool.put(std.parallelism.task!(TaskManager.doJob, Task)(t));
            return t.tid;
        }
        new KissTimer(_taskLoop).interval(d).onTick(delegate void(Object sender) {
            //trace("--- on tick ---: ", t.status);
            if (t.status == TaskStatus.FINISH || t.status == TaskStatus.CANCEL)
            {
                ITimer timer = cast(ITimer) sender;
                timer.stop();
            }
            else
            {
                taskPool.put(std.parallelism.task!(TaskManager.doJob, Task)(t));
            }
        }).start();
        return t.tid;
    }

    bool del(size_t tid)
    {
        _mutex.writer.lock();
        scope (exit)
            _mutex.writer.unlock();

        auto task = (tid in _tasks);
        if (task !is null)
        {
            auto ok = task.cancel();
            if (ok)
            {
                _tasks.remove(tid);
                trace("--del task : ", tid);
                return true;
            }
        }
        return false;
    }

private:
    bool add(Task t)
    {
        _mutex.writer.lock();
        scope (exit)
            _mutex.writer.unlock();

        auto task = (t.tid in _tasks);
        if (task !is null)
        {
            trace("--add same task : ", t.tid);
        }
        else
        {
            _tasks[t.tid] = t;
            trace("--add new task : ", t.tid);
            return true;
        }
        return false;
    }

}

private TaskManager _taskMInstance;

TaskManager GetTaskMObject()
{

    if (_taskMInstance is null)
    {
        _taskMInstance = new TaskManager();
    }
    return _taskMInstance;
}
