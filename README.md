# Signals vs Streams

Jan van Brügge

# What is a Stream?

Also called `Observable`, a sequence of <span style="color: yellow;">**events**</span> ordered by time. A stream <span style="color: yellow;">**pushes**</span> data from the producer to all <span style="color: yellow;">**consumers**</span>.

------------------

## In detail

```js
import fromEvent from 'xstream/extra/fromEvent';

const producer = fromEvent(document.body, 'click');

const consumer = {
    next: msg => console.log(msg),
    error: err => console.error(err),
    complete: () => console.log('complete')
};

producer.subscribe(consumer);
```

------------------

# What is a Signal?

Also called `Behavior`, a <span style="color: yellow;">**value**</span> that varies over time. A <span style="color: yellow;">**consumer**</span> has to <span style="color: yellow;">**pull**</span> data from the producer.

------------------

## In detail

```js
import { fromGetter } from 'ysignal'; //Not yet public

const signal = fromGetter(() => document.body.innerHTML);

console.log(signal.pull());

setTimeout(() => {
    console.log(signal.pull());
}, 100);
```

------------------

## Compare Stream vs Signals

|               | Stream             | Signal             |
|---------------|--------------------|--------------------|
| consumer role | passive            | active             | 
| naive type    | `[(Time, Event)]`  | `Time -> Value`    |

------------------

## Implementing a Stream

```js
import fromEvent from 'xstream/extra/fromEvent';

const producer = fromEvent(document.body, 'click');

const consumer = {
    next: msg => console.log(msg),
    error: err => console.error(err)
};

producer.subscribe(consumer);
```

------------------

## Implementing a Stream

```js
const producer = {
    subscribe(observer) {
        try {
            document.body.addEventListener('click', event => {
                observer.next(event);
            });
        } catch(e) {
            observer.error(e);
        }
    }
};

const consumer = {
    next: msg => console.log(msg),
    error: err => console.error(err)
}:

producer.subscribe(consumer);
```

------------------

## Cleanup

```js
function fromEvent(element, type) {
    return {
        subscribe(observer) {
            try {
                element.addEventListener(type, event => {
                    observer.next(event);
                });
            } catch (e) {
                observer.error(e);
            }
        }
    };
}

const producer = fromEvent(document.body, 'click');

const consumer = {
    next: msg => console.log(msg),
    error: err => console.error(err)
};

producer.subscribe(consumer);
```

------------------

## Implementing a Signal

```js
import { fromGetter } from 'ysignal'; //Not yet public

const signal = fromGetter(() => document.body.innerHTML);

console.log(signal.pull());

setTimeout(() => {
    console.log(signal.pull());
}, 100);
```

------------------

## Implementing a Signal

```js
const signal = {
    pull() {
        return document.body.innerHTML;
    }
}

console.log(signal.pull());

setTimeout(() => {
    console.log(signal.pull());
}, 100);
```

------------------

## Cleanup

```js
function fromGetter(getter) {
    return {
        pull() {
            return getter();
        }
    }
}

const signal = fromGetter(() => document.body.innerHTML);

console.log(signal.pull());

setTimeout(() => {
    console.log(signal.pull());
}, 100);
```

------------------

# So what?

Ok, I can implement it, but what are the benefits of Signals and Streams?


------------------

## Without streams

```js
import { patchDOM } from './virtual-dom-patcher';

function view(clicks) {
    return div([
        span('Number of clicks: ' + clicks)
    ]);
}

let clicks = 0;

patchDOM(view(clicks));

document.body.addListener('click', () => {
    clicks++;
    patchDOM(view(clicks));
});
```

------------------

## With streams

```js
import { patchDOM } from './virtual-dom-patcher';

function view(clicks) {
    return div([
        span('Number of clicks: ' + clicks)
    ]);
}

function applicationLogic(click$) {
    return click$
        .scan(acc => acc + 1)
        .map(view)
}

applicationLogic(fromEvent(document.body, 'click'))
    .subscribe({
        next: patchDOM
    });
```

------------------

## With streams - testing

```js
function applicationLogic(click$) {
    return click$
        .fold(acc => acc + 1, 0)
        .map(view)
}

it('should display 5 clicks', done => {
    const mockClick$ = xs.of(null, null, null, null, null);

    const result$ = applicationLogic(mockClick$);

    result$.last().subscribe({
        next: dom => {
            assertEquals(
                dom.children[0].text, 'Number of clicks: 5'
            );
            done();
        }
    });
});
```

------------------

## Why signals then?

Can anyone spot the bug in the code from earlier?

```js
function view(clicks) {
    return div([
        span('Number of clicks: ' + clicks)
    ]);
}

function applicationLogic(click$) {
    return click$
        .scan(acc => acc + 1)
        .map(view)
}

applicationLogic(fromEvent(document.body, 'click'))
    .subscribe({
        next: patchDOM
    });
```

------------------

## With Signals

```js
function view(clicks) {
    return div([
        span('Number of clicks: ' + clicks)
    ]);
}
function applicationLogic(click$) {
    return click$
        .scan(acc => acc + 1)
        .toSignal(0) //initial value
        .map(view)
}

const domSignal = applicationLogic(
    fromEvent(document.body, 'click')
);

const patch = () => requestAnimationFrame(() => {
    patchDOM(domSignal.pull()); patch();
});
patch();
```


