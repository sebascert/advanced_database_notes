Exercise 1 — Model Design

1. What relationships should Comment have?

The Comment entity should be associated with both Task and User because each
comment is authored by a user and belongs to a specific task.

2. Should Task have a comments relationship?

Yes. Since a task can receive multiple comments throughout its lifecycle, a
one-to-many relationship between Task and Comment is appropriate.

3. What should happen to comments when a task is deleted?

Comments related to a deleted task should also be removed automatically to
avoid orphaned records and preserve data integrity.

```python
class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True)
    task_id = Column(Integer, ForeignKey("tasks.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    content = Column(Text, nullable=False)
    created_at = Column(
        DateTime,
        server_default=func.current_timestamp()
    )

    task = relationship("Task", back_populates="comments")
    user = relationship("User")

    def __repr__(self):
        return f"<Comment {self.id}>"
```

```python
comments = relationship(
    "Comment",
    back_populates="task",
    cascade="all, delete-orphan"
)
```

Exercise 2 — Migration Creation

1. What does upgrade() do?

The `upgrade()` function applies the changes defined in the migration. In this
case, it creates the `comments` table along with its associated constraints.

2. What does downgrade() do?

The `downgrade()` function reverts the changes introduced by `upgrade()`,
restoring the database to its previous state.

3. What happens if you downgrade this migration?

Downgrading removes the `comments` table and permanently deletes any data
stored within it.

Bonus

```python
CheckConstraint("content <> ''", name="ck_comment_content")
```

Exercise 3 — CRUD Challenge

```python
with Session(engine) as session:

    # Create team
    devops = Team(
        name="DevOps",
        description="Operations and deployment team"
    )

    session.add(devops)
    session.commit()
    print("✓ Team registered")

    # Create user
    diana = User(
        username="diana_ops",
        email="diana@example.com",
        full_name="Diana Rodriguez",
        team=devops
    )

    session.add(diana)
    session.commit()
    print("✓ User registered")

    # Create tasks
    tasks = [
        Task(
            title="Implement CI/CD",
            description="Automate deployment pipeline",
            status="high",
            assignee=diana
        ),
        Task(
            title="Server Monitoring",
            description="Configure monitoring tools",
            status="medium",
            assignee=diana
        ),
        Task(
            title="Archive Old Logs",
            description="Remove outdated log files",
            status="low",
            assignee=diana
        )
    ]

    session.add_all(tasks)
    session.commit()
    print("✓ Tasks added")

    # Count tasks
    total_tasks = session.query(Task).count()
    print(f"Current task count: {total_tasks}")

    # Close a task
    tasks[0].status = "closed"
    session.commit()
    print(f"✓ Closed task: {tasks[0].title}")

    # Delete lowest-priority task
    session.delete(tasks[2])
    session.commit()
    print(f"✓ Removed task: {tasks[2].title}")
```

Exercise 4 — Migration Rollback

1. What happens to the column?

Rolling back the migration removes the `estimated_hours` column from the table
definition.

2. What happens to the data?

All values stored in the `estimated_hours` column are lost because the column
itself is removed from the schema.

Exercise 5 — Concept Check

1. Why use an ORM instead of raw SQL?

An ORM enables developers to work with database records as objects rather than
writing SQL for every operation. This reduces boilerplate code, improves
readability, and simplifies maintenance.

2. Why use migrations?

Migrations provide a controlled and versioned approach to database schema
changes, ensuring consistency across development, testing, and production
environments.

3. When would you perform a rollback?

A rollback is typically performed when a migration introduces errors, causes
unexpected behavior, or needs to be reverted to restore system stability.

4. What is the difference between add() and commit()?

`add()` places an object into the current database session, while `commit()`
persists all pending changes in that session to the database.

5. Why are relationships useful?

Relationships make it easier to navigate between related entities and allow
SQLAlchemy to automatically manage joins, associations, and linked data.

