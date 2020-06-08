# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `In-Reply-To` header for threads [#7]
- Options to toggle idle mode [#11]
- Customizable keybinds [#18]
- Pagination [#12]

### Changed

- Prevent asking passwords on startup via GPG [#2]
- Use vim builtin mail syntax `syntax/mail.vim` [#8]
- Split idle mode into its own subprocess [#9]
- Improve table column size and position [#21]

### Fixed

- Outlook issue [#3]
- Opening large mailbox [#4]
- Make use of `email.header.decode_header` to parse correctly headers [#6]
- Use `Reply-To` header to reply (if exists), otherwise `From` [#19]

### Security

- Hide passwords from logs [#20]

[unreleased]: https://github.com/soywod/iris.vim/tree/master

[#2]: https://github.com/soywod/iris.vim/issues/2
[#3]: https://github.com/soywod/iris.vim/issues/3
[#4]: https://github.com/soywod/iris.vim/issues/4
[#6]: https://github.com/soywod/iris.vim/issues/6
[#7]: https://github.com/soywod/iris.vim/issues/7
[#8]: https://github.com/soywod/iris.vim/issues/8
[#9]: https://github.com/soywod/iris.vim/issues/9
[#11]: https://github.com/soywod/iris.vim/issues/11
[#12]: https://github.com/soywod/iris.vim/issues/12
[#18]: https://github.com/soywod/iris.vim/issues/18
[#19]: https://github.com/soywod/iris.vim/issues/19
[#20]: https://github.com/soywod/iris.vim/issues/20
[#21]: https://github.com/soywod/iris.vim/issues/21
