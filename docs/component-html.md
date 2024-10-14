# HTML Page Example

The `HTML Page Type` provides core functionality for basic content.
This includes text and pictures, can can be formatted using common Web standards such as the _HyperText Markup Language_ (HTML) and the _Cascading Style Sheets_ (CSS).
This also includes support for hyperlinks connecting to external resources. While not all content creators will be familiar with these Web technologies, they are quite common allowing for easy access to trained designers.

## Typical screenshot
<img src="screenshot-html.png" alt="Screenshot with HTML Page example" style="width:300px;"/>
<br/>
Screenshot: HTML Page example

## Typical definition

```json
    {
      "id": "declaration-helsinki",
      "type": "html",
      "content": "https://storage.googleapis.com/[...]/declaration-helsinki-content.html"
    }
```
_OR_
```json
    {
      "id": "declaration-helsinki",
      "type": "html",
      "content": "You can define content directly as text. Inline text can be <b>formatted</b> as per the <i>HTML</i> syntax."
    }
```