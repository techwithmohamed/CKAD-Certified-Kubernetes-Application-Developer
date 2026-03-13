# Contributing

Thanks for wanting to improve this guide. Here's how to help.

## What's useful

- Fixing outdated information (Kubernetes version changes, exam format updates)
- Adding practice exercises that match the current CKAD curriculum
- Correcting YAML errors or broken commands
- Improving explanations that are unclear
- Adding missing topics from the [official CKAD curriculum](https://github.com/cncf/curriculum)

## How to contribute

1. Fork this repo
2. Create a branch: `git checkout -b fix/your-change`
3. Make your changes
4. Test any YAML or commands in a real cluster before submitting
5. Open a pull request with a clear description of what you changed and why

## Guidelines

- Keep the tone casual and first-person where it fits — this reads like study notes, not a textbook
- All YAML must be valid and tested. If you add a new exercise, include a working solution
- Don't add content that isn't relevant to the CKAD exam
- Don't share actual exam questions — this violates the CNCF certification agreement
- Keep file structure clean. Exercises go in `exercises/`, skeletons go in `skeletons/`

## Reporting issues

If something is wrong or outdated, open an issue. Include:
- What's incorrect
- What the correct information is (with a source if possible)
- Which section of the README it's in

## Code of Conduct

Be respectful. We're all here to help people pass the CKAD.
