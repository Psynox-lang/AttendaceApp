from sqlalchemy import Column, Date, Time, Boolean

from database import Base


class Attendance(Base):
    __tablename__ = "attendance"

    date = Column(Date, primary_key=True)

    check_in = Column(Time)

    check_out = Column(Time, nullable=True)

    approved = Column(Boolean, default=False)