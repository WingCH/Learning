import * as ff from '@google-cloud/functions-framework';

ff.http('TypescriptFunction', (req: ff.Request, res: ff.Response) => {
    switch (req.path) {
        case '/helloworld1':
            res.send('helloworld1');
            break;
        case '/helloworld2':
            res.send('helloworld2');
            break;
        default:
            res.status(404).send('Not Found');
    }
});
